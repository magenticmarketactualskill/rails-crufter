# frozen_string_literal: true

module RailsCrufter
  class FileProcessor
    attr_reader :template_manager

    def initialize(template_manager = nil)
      @template_manager = template_manager || TemplateManager.new
    end

    # Process a file with extended naming convention
    # Example: File.html._styling._layout._content
    def process_extended_naming(file_path, context = {})
      parsed = parse_template_chain(file_path)
      
      if parsed[:templates].empty?
        # No extended naming, just return the file path
        return file_path
      end

      # Apply template chain
      apply_template_chain(parsed[:base], parsed[:templates], context)
    rescue StandardError => e
      raise FileProcessingError, "Failed to process extended naming: #{e.message}"
    end

    # Parse filename to extract base and template chain
    # Input: "File.html._styling._layout._content"
    # Output: { base: "File.html", templates: ["content", "layout", "styling"] }
    def parse_template_chain(filename)
      # Get the basename without directory
      basename = File.basename(filename)
      dirname = File.dirname(filename)
      
      # Split by dots
      parts = basename.split(".")
      
      # Find where template chain starts (parts starting with _)
      template_start_index = parts.index { |part| part.start_with?("_") }
      
      if template_start_index.nil?
        # No template chain
        return { base: filename, templates: [] }
      end

      # Base is everything before template chain
      base_parts = parts[0...template_start_index]
      base_name = base_parts.join(".")
      
      # Templates are everything after, reversed (process from innermost to outermost)
      template_parts = parts[template_start_index..-1]
      templates = template_parts.map { |t| t.sub(/^_/, "") }.reverse
      
      {
        base: File.join(dirname, base_name),
        templates: templates
      }
    end

    # Apply a chain of templates sequentially
    def apply_template_chain(base_file, templates, context = {})
      current_file = base_file
      current_content = context[:initial_content] || ""
      
      templates.each_with_index do |template_name, index|
        # Build intermediate filename
        intermediate_file = build_intermediate_filename(base_file, templates, index)
        
        # Apply template
        template_context = context.merge(
          content: current_content,
          template_name: template_name
        )
        
        # Process template
        current_content = apply_single_template(template_name, template_context)
        
        # Save intermediate result
        FileUtils.mkdir_p(File.dirname(intermediate_file))
        File.write(intermediate_file, current_content)
        
        current_file = intermediate_file
      end
      
      current_file
    end

    # Build intermediate filename for template chain
    # Example: base="File.html", templates=["content", "layout", "styling"], index=0
    # Result: "File.html._styling._layout"
    def build_intermediate_filename(base_file, templates, current_index)
      remaining_templates = templates[(current_index + 1)..-1]
      
      if remaining_templates.empty?
        base_file
      else
        base_name = File.basename(base_file)
        dir_name = File.dirname(base_file)
        template_suffix = remaining_templates.reverse.map { |t| "._#{t}" }.join
        File.join(dir_name, "#{base_name}#{template_suffix}")
      end
    end

    # Check if filename uses extended naming
    def uses_extended_naming?(filename)
      basename = File.basename(filename)
      basename.include?("._")
    end

    private

    def apply_single_template(template_name, context)
      # Look for template file
      template_path = find_template_file(template_name)
      
      unless template_path
        raise FileProcessingError, "Template not found: #{template_name}"
      end

      # Read and process template
      template_content = File.read(template_path)
      process_template(template_content, context)
    end

    def find_template_file(template_name)
      # Look in templates directory
      possible_paths = [
        File.join(@template_manager.templates_root, "partials", "#{template_name}.erb"),
        File.join(@template_manager.templates_root, "partials", "#{template_name}.html.erb"),
        File.join(@template_manager.templates_root, template_name, "template.erb")
      ]
      
      possible_paths.find { |path| File.exist?(path) }
    end

    def process_template(template_content, context)
      # Create binding with context
      template_binding = create_binding(context)
      
      # Process ERB
      erb = ERB.new(template_content, trim_mode: "-")
      erb.result(template_binding)
    end

    def create_binding(context)
      context_object = Object.new
      
      context.each do |key, value|
        context_object.define_singleton_method(key) { value }
      end
      
      context_object.instance_eval { binding }
    end
  end
end
