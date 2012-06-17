require 'spec_helper'
require 'ostruct'
require 'validation/rule/matches'

describe Validation::Rule::Matches do
  let(:field) { :password_repeat }
  let(:obj) { OpenStruct.new(:password => 'foo', :password_repeat => 'bar') }
  subject { Validation::Rule::Matches.new(field) }

  it 'has an error key' do
    subject.error_key.should == :matches
  end

  it 'returns it\'s parameters' do
    subject.params.should == field
  end

  it 'accepts a data object' do
    subject.obj = obj
  end

  it 'passes on valid data' do
    subject.obj = obj
    subject.valid_value?('bar').should be_true
  end

  it 'fails on invalid data' do
    subject.obj = obj
    subject.valid_value?('foo').should be_false
  end

end
