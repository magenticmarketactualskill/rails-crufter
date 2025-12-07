# frozen_string_literal: true

module RailsCrufter
  module Generators
    class ControllerGenerator < GeneratorBase
      desc "Generate a controller with atomic-cookie-crufter templates"
      
      argument :name, type: :string, desc: "Controller name"
      argument :actions, type: :array, default: [], banner: "action action"
      
      class_option :skip_routes, type: :boolean, default: false, desc: "Skip routes"
      class_option :skip_helper, type: :boolean, default: false, desc: "Skip helper"
      
      def create_controller_file
        ensure_atomiccookiecrufter_initialized
        
        template_context = {
          class_name: controller_class_name,
          file_name: file_name,
          actions: actions,
          parent_class: "ApplicationController"
        }
        
        destination = File.join("app/controllers", "#{file_name}_controller.rb")
        create_from_template(:controller, destination, template_context)
      end
      
      def create_view_files
        actions.each do |action|
          template_context = {
            controller_name: file_name,
            action: action
          }
          
          destination = File.join("app/views", file_name, "#{action}.html.erb")
          create_from_template(:view, destination, template_context)
        end
      end
      
      def create_helper_file
        return if options[:skip_helper]
        
        template_context = {
          module_name: "#{controller_class_name}Helper"
        }
        
        destination = File.join("app/helpers", "#{file_name}_helper.rb")
        create_from_template(:helper, destination, template_context)
      end
      
      def add_routes
        return if options[:skip_routes] || actions.empty?
        
        route_code = actions.map { |action| "get '#{file_name}/#{action}'" }.join("\n  ")
        route route_code
      end
      
      private
      
      def controller_class_name
        "#{name.camelize}Controller"
      end
      
      def file_name
        name.underscore
      end
    end
  end
end
