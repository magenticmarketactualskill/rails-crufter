# Rails-Crufter Setup Guide

This guide provides detailed instructions for setting up the `rails-crufter` gem and its dependencies. Following these steps will ensure that your environment is correctly configured to use `rails-crufter` for generating code in your Rails projects.

## Prerequisites

Before you begin, ensure you have the following software installed on your system:

- **Ruby**: Version 3.3.6 or higher
- **Python**: Version 3.12 or higher
- **Git**: For cloning the `atomic-cookie-crufter` repository
- **Bundler**: For managing Ruby gem dependencies

## Step 1: Install Ruby

We recommend using `rbenv` to manage your Ruby versions. If you don\'t have `rbenv` installed, you can install it using the following command:

```bash
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
```

Once `rbenv` is installed, add it to your shell\'s startup script (e.g., `.bashrc`, `.zshrc`):

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

Now, you can install Ruby 3.3.6:

```bash
rbenv install 3.3.6
rbenv global 3.3.6
```

Verify your Ruby installation:

```bash
ruby -v
# Should output: ruby 3.3.6...
```

## Step 2: Install Python

`rails-crufter` requires Python 3.12. You can install it using your system\'s package manager or by downloading it from the official [Python website](https://www.python.org/downloads/).

### On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install python3.12 python3.12-venv
```

### On macOS (using Homebrew):

```bash
brew install python@3.12
```

Verify your Python installation:

```bash
python3.12 --version
# Should output: Python 3.12...
```

## Step 3: Install the Rails-Crufter Gem

Add `rails-crufter` to your Rails application\'s `Gemfile`:

```ruby
gem 'rails-crufter', git: 'https://github.com/your-username/rails-crufter.git'
```

Then, install the gem using Bundler:

```bash
bundle install
```

## Step 4: Set Up the Python Environment

`rails-crufter` provides a setup script to create the required Python virtual environment and install `atomic-cookie-crufter`.

From the root of your Rails application, run:

```bash
rails g rails_crufter:install
```

This command will:

1.  Create a Python virtual environment in the `.venv` directory of your project.
2.  Activate the virtual environment.
3.  Install the `atomic-cookie-crufter` library from its GitHub repository.
4.  Initialize `atomic-cookie-crufter` in your project by creating the `.atomiccookiecrufter` directory.

## Step 5: Configure Your Rails Application

To replace the default Rails generators with `rails-crufter`\'s generators, you need to configure your application in `config/application.rb`.

Add the following code inside the `class Application` block:

```ruby
config.generators do |g|
  # Set rails-crufter as the primary generator for scaffolds, models, etc.
  g.scaffold_generator = :rails_crufter_scaffold
  g.model_generator = :rails_crufter_model
  g.controller_generator = :rails_crufter_controller
  # Add other generators as needed
end
```

This configuration tells Rails to use the generators provided by `rails-crufter` instead of the built-in ones.

## Step 6: Verification

To verify that `rails-crufter` is set up correctly, you can run one of the generators:

```bash
rails generate model User name:string email:string:uniq
```

You should see output indicating that `rails-crufter` is being used to generate the files. You can also check for the presence of the `.atomiccookiecrufter` directory in your project root, which confirms that template tracking is active.

Additionally, you can use the `rails-crufter` command-line tools to interact with the template tracking system:

```bash
# Check the status of your templates
rails-crufter check

# Validate the mirror structure
rails-crufter validate
```

Congratulations! You have successfully set up `rails-crufter` in your Rails project. You can now leverage the power of atomic template management for your code generation needs.
