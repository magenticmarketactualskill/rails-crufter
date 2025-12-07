# frozen_string_literal: true

module RailsCrufter
  module Generators
    class ModelGenerator < GeneratorBase
      desc "Generate a model with atomic-cookie-crufter templates"
      
      argument :name, type: :string, desc: "Model name"
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      
      class_option :skip_migration, type: :boolean, default: false, desc: "Skip migration"
      class_option :parent, type: :string, desc: "Parent class for the model"
      
      def create_model_file
        ensure_atomiccookiecrufter_initialized
        
        template_context = {
          class_name: class_name,
          file_name: file_name,
          table_name: table_name,
          parent_class: options[:parent] || "ApplicationRecord",
          attributes: parsed_attributes
        }
        
        destination = File.join("app/models", "#{file_name}.rb")
        create_from_template(:model, destination, template_context)
      end
      
      def create_migration
        return if options[:skip_migration]
        
        template_context = {
          class_name: "Create#{class_name.pluralize}",
          table_name: table_name,
          attributes: parsed_attributes,
          migration_version: migration_version
        }
        
        migration_file = "#{timestamp}_create_#{table_name}.rb"
        destination = File.join("db/migrate", migration_file)
        create_from_template(:migration, destination, template_context)
      end
      
      private
      
      def class_name
        name.camelize
      end
      
      def file_name
        name.underscore
      end
      
      def table_name
        name.underscore.pluralize
      end
      
      def timestamp
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
      
      def parsed_attributes
        attributes.map do |attr|
          name, type = attr.split(":")
          type ||= "string"
          
          # Parse modifiers like {10} or {10,2}
          if type =~ /(\w+)\{(.+)\}/
            base_type = $1
            modifiers = $2
            
            if modifiers.include?(",")
              # Decimal with precision and scale
              precision, scale = modifiers.split(",")
              {
                name: name,
                type: base_type,
                precision: precision.to_i,
                scale: scale.to_i
              }
            else
              # String or integer with limit
              {
                name: name,
                type: base_type,
                limit: modifiers.to_i
              }
            end
          else
            {
              name: name,
              type: type
            }
          end
        end
      end
    end
  end
end
