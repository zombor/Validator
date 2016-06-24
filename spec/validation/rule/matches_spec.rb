require 'spec_helper'
require 'ostruct'
require 'validation/rule/matches'

describe Validation::Rule::Matches do
  let(:field) { :password_repeat }
  let(:obj) { OpenStruct.new(:password => 'foo', :password_repeat => 'bar') }
  subject { Validation::Rule::Matches.new(field) }

  it 'has an error key' do
    expect(subject.error_key).to eq(:matches)
  end

  it 'returns its parameters' do
    expect(subject.params).to eq(field)
  end

  it 'accepts a data object' do
    expect { subject.obj = obj }.not_to raise_error
  end

  it 'passes on valid data' do
    subject.obj = obj
    expect(subject.valid_value?('bar')).to eq(true)
  end

  it 'fails on invalid data' do
    subject.obj = obj
    expect(subject.valid_value?('foo')).to eq(false)
  end

end
