# frozen_string_literal: true

require "open3"
require "fileutils"

module RailsCrufter
  class PythonBridge
    attr_reader :venv_path, :python_executable, :pip_executable, :atomiccookiecrufter_cli

    def initialize(config = RailsCrufter.configuration)
      @config = config
      @venv_path = detect_venv_path
      @python_executable = File.join(@venv_path, "bin", "python")
      @pip_executable = File.join(@venv_path, "bin", "pip")
      @atomiccookiecrufter_cli = File.join(@venv_path, "bin", "atomiccookiecrufter")
    end

    # Check if Python environment is set up
    def environment_ready?
      File.exist?(@python_executable) && 
        File.exist?(@atomiccookiecrufter_cli)
    end

    # Setup Python virtual environment and install atomic-cookie-crufter
    def setup_environment
      unless File.exist?(@venv_path)
        create_venv
      end

      unless atomiccookiecrufter_installed?
        install_atomiccookiecrufter
      end

      true
    rescue StandardError => e
      raise PythonEnvironmentError, "Failed to setup Python environment: #{e.message}"
    end

    # Initialize atomic-cookie-crufter in the project
    def init_project
      execute_command("init")
    end

    # Link a path to a template
    def link_template(path, template_url, commit = "HEAD")
      execute_command("link", path, template_url, "--commit", commit)
    end

    # Validate mirror structure
    def validate
      result = execute_command("validate")
      result[:success]
    end

    # Check template status
    def check
      execute_command("check")
    end

    # Get project info
    def info
      execute_command("info")
    end

    private

    def detect_venv_path
      # Check if venv exists in Rails root
      if defined?(Rails) && Rails.root
        rails_venv = File.join(Rails.root, @config.venv_path)
        return rails_venv if File.exist?(rails_venv)
      end

      # Check current directory
      local_venv = File.join(Dir.pwd, @config.venv_path)
      return local_venv if File.exist?(local_venv)

      # Default to Rails root or current directory
      if defined?(Rails) && Rails.root
        File.join(Rails.root, @config.venv_path)
      else
        File.join(Dir.pwd, @config.venv_path)
      end
    end

    def create_venv
      puts "Creating Python virtual environment at #{@venv_path}..."
      
      # Find Python 3.12 or use python3
      python_cmd = find_python_command
      
      stdout, stderr, status = Open3.capture3("#{python_cmd} -m venv #{@venv_path}")
      
      unless status.success?
        raise PythonEnvironmentError, "Failed to create venv: #{stderr}"
      end

      puts "Virtual environment created successfully."
    end

    def find_python_command
      # Try to find Python 3.12 first, then fall back to python3
      ["python3.12", "python3", "python"].each do |cmd|
        stdout, _stderr, status = Open3.capture3("which #{cmd}")
        return cmd if status.success? && !stdout.strip.empty?
      end

      raise PythonEnvironmentError, "Python 3 not found. Please install Python 3.12 or higher."
    end

    def install_atomiccookiecrufter
      puts "Installing atomic-cookie-crufter..."
      
      # Clone the repository to a temporary directory
      temp_dir = File.join(Dir.tmpdir, "atomic-cookie-crufter-#{Time.now.to_i}")
      
      stdout, stderr, status = Open3.capture3("git clone #{@config.atomiccookiecrufter_repo} #{temp_dir}")
      
      unless status.success?
        raise PythonEnvironmentError, "Failed to clone atomic-cookie-crufter: #{stderr}"
      end

      # Install from local directory
      stdout, stderr, status = Open3.capture3("#{@pip_executable} install -e #{temp_dir}")
      
      unless status.success?
        FileUtils.rm_rf(temp_dir)
        raise PythonEnvironmentError, "Failed to install atomic-cookie-crufter: #{stderr}"
      end

      puts "atomic-cookie-crufter installed successfully."
      
      # Clean up temp directory
      FileUtils.rm_rf(temp_dir)
    end

    def atomiccookiecrufter_installed?
      return false unless File.exist?(@pip_executable)
      
      stdout, _stderr, status = Open3.capture3("#{@pip_executable} show atomiccookiecrufter")
      status.success?
    end

    def execute_command(*args)
      unless environment_ready?
        raise PythonEnvironmentError, "Python environment not ready. Run setup first."
      end

      command = "#{@atomiccookiecrufter_cli} #{args.join(' ')}"
      stdout, stderr, status = Open3.capture3(command)

      {
        success: status.success?,
        stdout: stdout,
        stderr: stderr,
        exit_code: status.exitstatus
      }
    end
  end
end
