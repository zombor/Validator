require 'spec_helper'

describe Validation::Rule::Phone do
  subject do
    described_class.new(:field, params)
  end

  let(:params) { Hash.new }

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:phone)
  end

  it 'does not validate a blank value' do
    expect(subject).to be_valid_for(nil)
    expect(subject).to be_valid_for('')
  end

  it 'defaults to USA format' do
    expect(subject.options[:format]).to eq(:usa)
  end

  context 'USA' do
    let(:params) do
      { format: :usa }
    end

    it 'passes for valid values' do
      [
        '2025550100',
        '202-555-0100',
        '12025550100',
        '+1-202-555-0100'
      ].each do |value|
        expect(subject).to be_valid_for(value)
      end
    end

    it 'fails for invalid values' do
      [
        'whatever',
        '123456',
        '123456789',
        '123456789012'
      ].each do |value|
        expect(subject).to have_error_for(value, :invalid)
      end
    end
  end
end
