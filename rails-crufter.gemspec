# frozen_string_literal: true

require_relative "lib/rails_crufter/version"

Gem::Specification.new do |spec|
  spec.name = "rails-crufter"
  spec.version = RailsCrufter::VERSION
  spec.authors = ["Rails Crufter Team"]
  spec.email = ["team@railscrufter.dev"]

  spec.summary = "Replace Rails generators with atomic-cookie-crufter templates"
  spec.description = "A Ruby gem that replaces Rails generators with atomic-cookie-crufter templates, " \
                     "supporting extended Rails file naming conventions and template tracking."
  spec.homepage = "https://github.com/railscrufter/rails-crufter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/railscrufter/rails-crufter"
  spec.metadata["changelog_uri"] = "https://github.com/railscrufter/rails-crufter/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "thor", "~> 1.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "rubocop", "~> 1.0"
end
