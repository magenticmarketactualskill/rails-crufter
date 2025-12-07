# Rails-Crufter

Rails-Crufter is a Ruby gem that replaces Rails generators with atomic-cookie-crufter templates, supporting extended Rails file naming conventions and template tracking.

## Features

- **Atomic Template Management**: Uses atomic-cookie-crufter for template tracking and management
- **Extended File Naming**: Supports Rails extended naming like `File.html._styling._layout._content`
- **Template Tracking**: Automatically tracks which templates generated which files
- **Python Integration**: Seamlessly integrates with Python 3.12 and atomic-cookie-crufter
- **Drop-in Replacement**: Works as a drop-in replacement for Rails generators

## Requirements

- Ruby 3.3.6 or higher
- Rails 7.0 or higher
- Python 3.12 or higher
- Git

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-crufter'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rails-crufter
```

## Setup

After installing the gem, you need to set up the Python environment:

```bash
rails-crufter setup
```

This will:
1. Create a Python 3.12 virtual environment in `.venv`
2. Install atomic-cookie-crufter from the official repository
3. Initialize atomic-cookie-crufter in your Rails project

## Usage

### Basic Generators

Rails-Crufter provides drop-in replacements for all standard Rails generators:

```bash
# Generate a model
rails generate model Post title:string body:text

# Generate a controller
rails generate controller Posts index show

# Generate a scaffold
rails generate scaffold Post title:string body:text published:boolean
```

### Extended File Naming

Rails-Crufter supports extended file naming conventions for template composition:

```
File.html._styling._layout._content
```

This will process templates in sequence:
1. `_content` template is applied first
2. Result is passed to `_layout` template
3. Final result is passed to `_styling` template

Each intermediate result is saved, allowing you to see the transformation at each step.

### Template Tracking

All generated files are automatically tracked using atomic-cookie-crufter's mirror system. You can:

```bash
# Check template status
rails-crufter check

# Validate mirror structure
rails-crufter validate

# View configuration
rails-crufter info
```

## Configuration

Configure Rails-Crufter in an initializer (`config/initializers/rails_crufter.rb`):

```ruby
RailsCrufter.configure do |config|
  config.python_version = "3.12"
  config.venv_path = ".venv"
  config.templates_path = "lib/templates"
  config.track_templates = true
end
```

### Integrating with Rails Generators

Add to `config/application.rb`:

```ruby
config.generators do |g|
  g.orm :active_record
  g.template_engine :erb
  g.test_framework :rspec
  
  # Use rails-crufter generators
  g.model_generator = RailsCrufter::Generators::ModelGenerator
  g.controller_generator = RailsCrufter::Generators::ControllerGenerator
  g.scaffold_generator = RailsCrufter::Generators::ScaffoldGenerator
end
```

## Available Generators

- `model` - Generate model and migration
- `controller` - Generate controller and views
- `scaffold` - Generate complete CRUD interface
- `migration` - Generate database migration
- `mailer` - Generate mailer class
- `job` - Generate Active Job
- `channel` - Generate Action Cable channel
- `resource` - Generate model, controller, and routes
- `helper` - Generate helper module
- `task` - Generate Rake task
- `initializer` - Generate initializer file

## Extended Naming Examples

### View with Layout and Styling

```
app/views/posts/index.html._styling._layout._content.erb
```

Processing order:
1. `_content.erb` - Main content
2. `_layout.erb` - Wraps content in layout
3. `_styling.erb` - Applies styling

### Component with Multiple Layers

```
app/components/card.html._theme._structure._content.erb
```

Each template receives the output of the previous template as `content` variable.

## Template Structure

Templates are stored in `lib/templates/` by default:

```
lib/templates/
├── model/
│   └── template.rb.tt
├── controller/
│   └── template.rb.tt
├── scaffold/
│   ├── controller.rb.tt
│   └── views/
│       ├── index.html.erb
│       ├── show.html.erb
│       ├── new.html.erb
│       ├── edit.html.erb
│       └── _form.html.erb
└── partials/
    ├── _content.erb
    ├── _layout.erb
    └── _styling.erb
```

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
# Run RSpec tests
bundle exec rspec

# Run Cucumber features
bundle exec cucumber

# Run all tests
bundle exec rake
```

## Testing

Rails-Crufter includes comprehensive test coverage using:

- **RSpec** for unit tests
- **Cucumber** for integration tests
- **SimpleCov** for code coverage

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/railscrufter/rails-crufter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

- [atomic-cookie-crufter](https://github.com/magenticmarketactualskill/atomic-cookie-crufter) - Template management system
- [Rails](https://rubyonrails.org/) - Web application framework
- [Thor](https://github.com/rails/thor) - Command-line interface toolkit

## Support

For issues, questions, or contributions, please visit:
- GitHub Issues: https://github.com/railscrufter/rails-crufter/issues
- Documentation: https://github.com/railscrufter/rails-crufter/wiki
