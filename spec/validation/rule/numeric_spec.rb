require 'spec_helper'

describe Validation::Rule::Numeric do
  subject do
    described_class.new(:field, params)
  end

  let(:params) { Hash.new }

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:numeric)
  end

  it 'does not validate a blank value' do
    expect(subject).to be_valid_for(nil)
    expect(subject).to be_valid_for('')
  end

  it 'fails if value is not numerical' do
    ['abc', '123abc', 'abc123', '12.34.56', '+-123'].each do |value|
      expect(subject).to have_error_for(value, :invalid)
    end
  end

  context 'default options' do
    let(:params) { Hash.new }

    it 'passes if value represents an integer' do
      [123, 123.0, '123', '123.0', '+123', '-123.0'].each do |value|
        expect(subject).to be_valid_for(value)
      end
    end

    it 'fails if value is not a whole integer' do
      [123.4, '123.4', '-123.4'].each do |value|
        expect(subject).to have_error_for(value, :not_round)
      end
    end
  end

  context 'minimum' do
    let(:params) do
      { minimum: 3.5, decimals: 3 }
    end

    it 'passes if the value is big enough' do
      expect(subject).to be_valid_for(3.5)
      expect(subject).to be_valid_for(10 ** 10)
    end

    it 'fails if the value is too small' do
      expect(subject).to have_error_for(3.499, :too_small)
      expect(subject).to have_error_for(-10 ** 10, :too_small)
    end
  end

  context 'maximum' do
    let(:params) do
      { maximum: 3.5, decimals: 3 }
    end

    it 'passes if the value is small enough' do
      expect(subject).to be_valid_for(3.5)
      expect(subject).to be_valid_for(-10 ** 10)
    end

    it 'fails if the value is too large' do
      expect(subject).to have_error_for(3.501, :too_large)
      expect(subject).to have_error_for(10 ** 10, :too_large)
    end
  end

  context 'both' do
    let(:params) do
      { minimum: 0.5, maximum: 1.5, decimals: 3 }
    end

    it 'passes if the value is within the limits' do
      expect(subject).to be_valid_for(0.5)
      expect(subject).to be_valid_for(1.5)
    end

    it 'fails if the value is outside the limits' do
      expect(subject).to have_error_for(0.499, :too_small)
      expect(subject).to have_error_for(1.501, :too_large)
    end
  end

  context 'range' do
    let(:params) do
      { range: 0.5..1.5, decimals: 3 }
    end

    it 'passes if the value is within the limits' do
      expect(subject).to be_valid_for(0.5)
      expect(subject).to be_valid_for(1.5)
    end

    it 'fails if the value is outside the limits' do
      expect(subject).to have_error_for(0.499, :too_small)
      expect(subject).to have_error_for(1.501, :too_large)
    end
  end

  context 'decimals' do
    let(:params) do
      { decimals: 3 }
    end

    it 'passes if the number of decimals does not exceed the limit' do
      ['1', '1.2', '1.23', '1.234', '1.23400'].each do |value|
        expect(subject).to be_valid_for(value)
      end
    end

    it 'fails if the number of decimals exceeds the limit' do
      ['1.2345', '1.23456789'].each do |value|
        expect(subject).to have_error_for(value, :not_round)
      end
    end
  end
end
