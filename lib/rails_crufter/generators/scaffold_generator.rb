# frozen_string_literal: true

module RailsCrufter
  module Generators
    class ScaffoldGenerator < GeneratorBase
      desc "Generate a complete scaffold with atomic-cookie-crufter templates"
      
      argument :name, type: :string, desc: "Resource name"
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      
      class_option :skip_migration, type: :boolean, default: false, desc: "Skip migration"
      class_option :skip_routes, type: :boolean, default: false, desc: "Skip routes"
      
      def create_model
        invoke ModelGenerator, [name] + attributes, skip_migration: options[:skip_migration]
      end
      
      def create_controller_file
        ensure_atomiccookiecrufter_initialized
        
        template_context = {
          class_name: controller_class_name,
          file_name: file_name,
          singular_name: singular_name,
          plural_name: plural_name,
          model_class: class_name,
          attributes: parsed_attributes
        }
        
        destination = File.join("app/controllers", "#{file_name}_controller.rb")
        create_from_template(:scaffold_controller, destination, template_context)
      end
      
      def create_view_files
        views = %w[index show new edit _form]
        
        views.each do |view|
          template_context = {
            singular_name: singular_name,
            plural_name: plural_name,
            model_class: class_name,
            attributes: parsed_attributes
          }
          
          view_file = view.start_with?("_") ? "#{view}.html.erb" : "#{view}.html.erb"
          destination = File.join("app/views", file_name, view_file)
          create_from_template(:scaffold_view, destination, template_context.merge(view_name: view))
        end
      end
      
      def create_helper_file
        template_context = {
          module_name: "#{controller_class_name}Helper"
        }
        
        destination = File.join("app/helpers", "#{file_name}_helper.rb")
        create_from_template(:helper, destination, template_context)
      end
      
      def add_resource_route
        return if options[:skip_routes]
        
        route "resources :#{plural_name}"
      end
      
      private
      
      def class_name
        name.camelize.singularize
      end
      
      def controller_class_name
        "#{plural_name.camelize}Controller"
      end
      
      def file_name
        name.underscore.pluralize
      end
      
      def singular_name
        name.underscore.singularize
      end
      
      def plural_name
        name.underscore.pluralize
      end
      
      def parsed_attributes
        attributes.map do |attr|
          attr_name, type = attr.split(":")
          type ||= "string"
          
          # Parse modifiers
          if type =~ /(\w+)\{(.+)\}/
            base_type = $1
            modifiers = $2
            
            if modifiers.include?(",")
              precision, scale = modifiers.split(",")
              {
                name: attr_name,
                type: base_type,
                precision: precision.to_i,
                scale: scale.to_i
              }
            else
              {
                name: attr_name,
                type: base_type,
                limit: modifiers.to_i
              }
            end
          else
            {
              name: attr_name,
              type: type
            }
          end
        end
      end
    end
  end
end
