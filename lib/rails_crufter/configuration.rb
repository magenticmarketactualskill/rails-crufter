# frozen_string_literal: true

module RailsCrufter
  class Configuration
    attr_accessor :python_version, :venv_path, :templates_path, :track_templates,
                  :atomiccookiecrufter_repo, :atomiccookiecrufter_commit

    def initialize
      @python_version = "3.12"
      @venv_path = ".venv"
      @templates_path = File.expand_path("../../templates", __dir__)
      @track_templates = true
      @atomiccookiecrufter_repo = "https://github.com/magenticmarketactualskill/atomic-cookie-crufter.git"
      @atomiccookiecrufter_commit = "main"
    end

    def venv_full_path
      File.join(Rails.root, @venv_path) if defined?(Rails)
    end
  end
end
