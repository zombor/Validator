require 'spec_helper'
require 'validation/rule/phone'

describe Validation::Rule::Phone do
  subject { Validation::Rule::Phone }

  it 'has an error key' do
    expect(subject.new.error_key).to eq(:phone)
  end

  it 'defaults to america format' do
    expect(subject.new.params).to eq(:format => :america)
  end

  context :america do
    let(:rule) { subject.new }
    it 'is valid' do
      [
        '1234567890',
        '11234567890'
      ].each do |phone|
        expect(rule.valid_value?(phone)).to eq(true)
      end
    end

    it 'is invalid' do
      [
        'asdfghjklp',
        '123456789',
        '123456789012'
      ].each do |phone|
        expect(rule.valid_value?(phone)).to eq(false)
      end
    end
  end
end
