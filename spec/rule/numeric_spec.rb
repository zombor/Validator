require 'spec_helper'
require 'validator/rule/numeric'

describe Validator::Rule::Numeric do
  it 'passes when a value is numeric' do
    subject.valid_value?(10).should be_true
  end

  it 'fails when a value is not numeric' do
    ['', nil, 'foo', 10.5].each do |value|
      subject.valid_value?(value).should be_false
    end
  end

  it 'has an error key' do
    subject.error_key.should == :numeric
  end

  it 'returns it\'s parameters' do
    subject.params.should == {}
  end
end
