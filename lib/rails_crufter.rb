# frozen_string_literal: true

require_relative "rails_crufter/version"
require_relative "rails_crufter/configuration"
require_relative "rails_crufter/python_bridge"
require_relative "rails_crufter/template_manager"
require_relative "rails_crufter/file_processor"
require_relative "rails_crufter/generator_base"

# Load all generators
Dir[File.join(__dir__, "rails_crufter", "generators", "*.rb")].each { |file| require file }

module RailsCrufter
  class Error < StandardError; end
  class PythonEnvironmentError < Error; end
  class TemplateError < Error; end
  class FileProcessingError < Error; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration
    @configuration = Configuration.new
  end
end
