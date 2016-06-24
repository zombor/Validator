require 'spec_helper'
require 'validation/rule/numeric'

describe Validation::Rule::Numeric do
  it 'passes when a value is numeric' do
    expect(subject.valid_value?(10)).to eq(true)
  end

  it 'fails when a value is not numeric' do
    ['', nil, 'foo', 10.5].each do |value|
      expect(subject.valid_value?(value)).to eq(false)
    end
  end

  it 'has an error key' do
    expect(subject.error_key).to eq(:numeric)
  end

  it 'returns its parameters' do
    expect(subject.params).to eq({})
  end
end
