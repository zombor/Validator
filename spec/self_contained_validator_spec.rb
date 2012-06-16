require 'spec_helper'
require 'validation'
require 'validation/rule/not_empty'
require 'ostruct'

class SelfContainedValidator < Validation::Validator
  include Validation

  rule :email, :not_empty
end

describe SelfContainedValidator do
  it 'works like a validator' do
    foo = SelfContainedValidator.new(OpenStruct.new(:email => 'foobar'))
    foo.valid?.should be_true
  end
end
