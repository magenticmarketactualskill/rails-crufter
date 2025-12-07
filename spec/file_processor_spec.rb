# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsCrufter::FileProcessor do
  let(:template_manager) { instance_double(RailsCrufter::TemplateManager) }
  let(:processor) { described_class.new(template_manager) }

  describe "#parse_template_chain" do
    it "parses filename without template chain" do
      result = processor.parse_template_chain("File.html.erb")
      expect(result[:base]).to eq("File.html.erb")
      expect(result[:templates]).to be_empty
    end

    it "parses filename with single template" do
      result = processor.parse_template_chain("File.html._content.erb")
      expect(result[:base]).to eq("File.html.erb")
      expect(result[:templates]).to eq(["content"])
    end

    it "parses filename with multiple templates" do
      result = processor.parse_template_chain("File.html._styling._layout._content.erb")
      expect(result[:base]).to eq("File.html.erb")
      expect(result[:templates]).to eq(["content", "layout", "styling"])
    end

    it "handles directory paths" do
      result = processor.parse_template_chain("app/views/File.html._layout._content.erb")
      expect(result[:base]).to eq("app/views/File.html.erb")
      expect(result[:templates]).to eq(["content", "layout"])
    end
  end

  describe "#uses_extended_naming?" do
    it "returns true for files with extended naming" do
      expect(processor.uses_extended_naming?("File.html._content.erb")).to be true
    end

    it "returns false for files without extended naming" do
      expect(processor.uses_extended_naming?("File.html.erb")).to be false
    end
  end

  describe "#build_intermediate_filename" do
    it "builds correct intermediate filename" do
      templates = ["content", "layout", "styling"]
      
      result = processor.build_intermediate_filename("File.html", templates, 0)
      expect(result).to eq("File.html._styling._layout")
      
      result = processor.build_intermediate_filename("File.html", templates, 1)
      expect(result).to eq("File.html._styling")
      
      result = processor.build_intermediate_filename("File.html", templates, 2)
      expect(result).to eq("File.html")
    end
  end
end
