require 'spec_helper'
require 'validation/rule/email'

describe Validation::Rule::Email do
  it 'passes with a valid email' do
    expect(subject.valid_value?('foo@bar.com')).to eq(true)
  end

  it 'fails with an invalid email' do
    ['bad-email', '', nil].each do |value|
      expect(subject.valid_value?(value)).to eq(false)
    end
  end

  it 'has an error key' do
    expect(subject.error_key).to eq(:email)
  end

  it 'returns its parameters' do
    expect(subject.params).to eq({})
  end
end
