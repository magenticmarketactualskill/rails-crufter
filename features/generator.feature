Feature: Rails Crufter Generators
  As a Rails developer
  I want to use atomic-cookie-crufter templates for code generation
  So that I can track and manage my generated code

  Scenario: Parse extended file naming
    Given a file processor
    When I parse the filename "File.html._styling._layout._content.erb"
    Then the base should be "File.html.erb"
    And the templates should be "content, layout, styling"

  Scenario: Detect extended naming
    Given a file processor
    When I check if "File.html._content.erb" uses extended naming
    Then it should return true
    When I check if "File.html.erb" uses extended naming
    Then it should return false
