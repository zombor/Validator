require 'spec_helper'
require 'validation/rule/email'

describe Validation::Rule::Email do
  it 'passes with a valid email' do
    subject.valid_value?('foo@bar.com').should be_true
  end

  it 'fails with an invalid email' do
    ['', nil].each do |value|
      subject.valid_value?(value).should be_false
    end
  end

  it 'has an error key' do
    subject.error_key.should == :email
  end

  it 'returns it\'s parameters' do
    subject.params.should == {}
  end
end
