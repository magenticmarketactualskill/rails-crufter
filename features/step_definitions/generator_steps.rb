# frozen_string_literal: true

Given("a file processor") do
  @processor = RailsCrufter::FileProcessor.new
end

When("I parse the filename {string}") do |filename|
  @result = @processor.parse_template_chain(filename)
end

Then("the base should be {string}") do |expected_base|
  expect(@result[:base]).to eq(expected_base)
end

Then("the templates should be {string}") do |expected_templates|
  templates = expected_templates.split(", ")
  expect(@result[:templates]).to eq(templates)
end

When("I check if {string} uses extended naming") do |filename|
  @uses_extended = @processor.uses_extended_naming?(filename)
end

Then("it should return true") do
  expect(@uses_extended).to be true
end

Then("it should return false") do
  expect(@uses_extended).to be false
end
