# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "rails_crufter"
require "fileutils"
require "tmpdir"

# Set up test environment
Before do
  @test_dir = Dir.mktmpdir("rails-crufter-test")
  @original_dir = Dir.pwd
  Dir.chdir(@test_dir)
end

After do
  Dir.chdir(@original_dir)
  FileUtils.rm_rf(@test_dir) if File.exist?(@test_dir)
end
