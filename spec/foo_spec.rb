require 'spec_helper'
require 'validator'
require 'validator/rule/not_empty'
require 'ostruct'

class Foo < Validator
  def initialize(thing)
    super(thing)
    rule :email, :not_empty
  end
end

describe Foo do
  it 'works like a validator' do
    foo = Foo.new(OpenStruct.new(:email => 'foobar'))
    puts foo.valid?.inspect
  end
end
