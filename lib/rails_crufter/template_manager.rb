# frozen_string_literal: true

require "erb"
require "json"

module RailsCrufter
  class TemplateManager
    attr_reader :python_bridge, :templates_root

    def initialize(python_bridge = nil, config = RailsCrufter.configuration)
      @python_bridge = python_bridge || PythonBridge.new(config)
      @config = config
      @templates_root = config.templates_path
    end

    # Apply a template with given context
    def apply_template(generator_type, destination, context = {})
      template_path = get_template_path(generator_type)
      
      unless File.exist?(template_path)
        raise TemplateError, "Template not found: #{template_path}"
      end

      # Read template content
      template_content = File.read(template_path)
      
      # Process ERB template
      result = process_erb_template(template_content, context)
      
      # Write result to destination
      FileUtils.mkdir_p(File.dirname(destination))
      File.write(destination, result)
      
      # Track template usage if enabled
      if @config.track_templates
        register_template_usage(destination, generator_type)
      end

      destination
    rescue StandardError => e
      raise TemplateError, "Failed to apply template: #{e.message}"
    end

    # Get template path for a generator type
    def get_template_path(generator_type)
      File.join(@templates_root, generator_type.to_s, "template.rb.tt")
    end

    # Get template directory for a generator type
    def get_template_dir(generator_type)
      File.join(@templates_root, generator_type.to_s)
    end

    # Register template usage with atomic-cookie-crufter
    def register_template_usage(file_path, template_name)
      return unless @python_bridge.environment_ready?

      # Get relative path from Rails root
      relative_path = if defined?(Rails) && Rails.root
                        Pathname.new(file_path).relative_path_from(Rails.root).to_s
                      else
                        file_path
                      end

      # Link the file to the template
      template_url = "rails-crufter://#{template_name}"
      @python_bridge.link_template(relative_path, template_url, RailsCrufter::VERSION)
    rescue StandardError => e
      # Don't fail if tracking fails, just warn
      warn "Warning: Failed to track template usage: #{e.message}"
    end

    # Check if a template exists
    def template_exists?(generator_type)
      File.exist?(get_template_path(generator_type))
    end

    # List available templates
    def available_templates
      return [] unless File.directory?(@templates_root)

      Dir.entries(@templates_root)
         .reject { |entry| entry.start_with?(".") }
         .select { |entry| File.directory?(File.join(@templates_root, entry)) }
    end

    private

    def process_erb_template(template_content, context)
      # Create a binding with the context variables
      template_binding = create_template_binding(context)
      
      # Process ERB
      erb = ERB.new(template_content, trim_mode: "-")
      erb.result(template_binding)
    end

    def create_template_binding(context)
      # Create an object that will serve as the binding context
      context_object = Object.new
      
      # Define methods for each context variable
      context.each do |key, value|
        context_object.define_singleton_method(key) { value }
      end
      
      context_object.instance_eval { binding }
    end
  end
end
