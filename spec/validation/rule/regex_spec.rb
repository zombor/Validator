require 'spec_helper'

describe Validation::Rule::Regex do
  subject do
    described_class.new(:field, regex: /\Aval(id|ue)-\d{2}\z/)
  end

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:regex)
  end

  it 'does not validate a blank value' do
    expect(subject).to be_valid_for(nil)
    expect(subject).to be_valid_for('')
  end

  it 'passes if value matches regex' do
    ['valid-12', 'value-34'].each do |value|
      expect(subject).to be_valid_for(value)
    end
  end

  it 'passes if value does not match regex' do
    ['invalid', 'value-1', 'valid-not'].each do |value|
      expect(subject).to have_error_for(value, :invalid)
    end
  end
end
