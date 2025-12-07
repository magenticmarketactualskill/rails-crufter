# frozen_string_literal: true

require "rails/generators"

module RailsCrufter
  class GeneratorBase < Rails::Generators::Base
    def initialize(args, *options)
      super
      @python_bridge = PythonBridge.new
      @template_manager = TemplateManager.new(@python_bridge)
      @file_processor = FileProcessor.new(@template_manager)
      
      # Ensure Python environment is set up
      ensure_environment_ready
    end

    protected

    # Create a file from template with optional extended naming support
    def create_from_template(template_name, destination, context = {})
      # Check if destination uses extended naming
      if @file_processor.uses_extended_naming?(destination)
        # Process with extended naming
        result_file = @file_processor.process_extended_naming(destination, context)
        say_status :create, result_file, :green
        result_file
      else
        # Standard template processing
        @template_manager.apply_template(template_name, destination, context)
        say_status :create, destination, :green
        destination
      end
    rescue StandardError => e
      say_status :error, "Failed to create #{destination}: #{e.message}", :red
      raise
    end

    # Copy a template file
    def copy_template_file(template_name, source_file, destination, context = {})
      template_dir = @template_manager.get_template_dir(template_name)
      source_path = File.join(template_dir, source_file)
      
      unless File.exist?(source_path)
        raise TemplateError, "Template file not found: #{source_path}"
      end

      # Read template
      template_content = File.read(source_path)
      
      # Process ERB if it's a .tt file
      if source_file.end_with?(".tt")
        template_content = process_erb(template_content, context)
      end
      
      # Write to destination
      FileUtils.mkdir_p(File.dirname(destination))
      File.write(destination, template_content)
      
      # Track template usage
      if RailsCrufter.configuration.track_templates
        @template_manager.register_template_usage(destination, template_name)
      end
      
      say_status :create, destination, :green
      destination
    end

    # Get template directory for this generator
    def template_dir
      @template_manager.get_template_dir(generator_type)
    end

    # Get generator type (override in subclasses)
    def generator_type
      self.class.name.split("::").last.gsub("Generator", "").downcase
    end

    # Process ERB template with context
    def process_erb(template_content, context)
      binding_context = create_binding_context(context)
      erb = ERB.new(template_content, trim_mode: "-")
      erb.result(binding_context)
    end

    # Create binding context from hash
    def create_binding_context(context)
      context_object = Object.new
      
      # Add instance variables from this generator
      instance_variables.each do |var|
        value = instance_variable_get(var)
        context_object.instance_variable_set(var, value)
      end
      
      # Add context variables
      context.each do |key, value|
        context_object.define_singleton_method(key) { value }
      end
      
      context_object.instance_eval { binding }
    end

    # Ensure Python environment is ready
    def ensure_environment_ready
      return if @python_bridge.environment_ready?
      
      say_status :setup, "Setting up Python environment...", :yellow
      @python_bridge.setup_environment
      say_status :setup, "Python environment ready", :green
    rescue PythonEnvironmentError => e
      say_status :error, "Python environment setup failed: #{e.message}", :red
      say_status :info, "Run 'rails-crufter setup' to manually setup the environment", :yellow
    end

    # Initialize atomic-cookie-crufter if not already initialized
    def ensure_atomiccookiecrufter_initialized
      config_dir = File.join(destination_root, ".atomiccookiecrufter")
      return if File.directory?(config_dir)
      
      say_status :init, "Initializing atomic-cookie-crufter...", :yellow
      @python_bridge.init_project
      say_status :init, "atomic-cookie-crufter initialized", :green
    rescue StandardError => e
      say_status :warning, "Failed to initialize atomic-cookie-crufter: #{e.message}", :yellow
    end
  end
end
