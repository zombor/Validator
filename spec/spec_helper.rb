require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift '../lib'

require 'validation'

RSpec::Matchers.define :be_valid_for do |value, object|
  match do |rule|
    context = Validation::Validator::Context.new(subject, object || Object.new)
    subject.validate(value, context)
    context.errors.empty?
  end
end

RSpec::Matchers.define :have_error_for do |value, *errors, object|
  match do |rule|
    context = Validation::Validator::Context.new(subject, object || Object.new)
    subject.validate(value, context)
    errors.all? { |error|
      context.errors.include?(error)
    }
  end
end