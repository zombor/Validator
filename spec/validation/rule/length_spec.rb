require 'spec_helper'

describe Validation::Rule::Length do
  subject do
    described_class.new(:field, params)
  end

  let(:params) { Hash.new }

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:length)
  end

  context 'minimum' do
    let(:params) do
      { minimum: 3 }
    end

    it 'does not validate a blank value' do
      expect(subject).to be_valid_for(nil)
      expect(subject).to be_valid_for('')
    end

    it 'passes if the value is long enough' do
      expect(subject).to be_valid_for('abc')
      expect(subject).to be_valid_for('abc-def')
    end

    it 'fails if the value is too short' do
      expect(subject).to have_error_for('ab', :too_short)
    end
  end

  context 'maximum' do
    let(:params) do
      { maximum: 3 }
    end

    it 'passes if the value is short enough' do
      expect(subject).to be_valid_for('a')
      expect(subject).to be_valid_for('abc')
    end

    it 'fails if the value is too long' do
      expect(subject).to have_error_for('abcd', :too_long)
    end
  end

  context 'both' do
    let(:params) do
      { minimum: 2, maximum: 4 }
    end

    it 'does not validate a blank value' do
      expect(subject).to be_valid_for(nil)
      expect(subject).to be_valid_for('')
    end

    it 'passes if the length is within the limits' do
      expect(subject).to be_valid_for('ab')
      expect(subject).to be_valid_for('abcd')
    end

    it 'fails if the length is outside the limits' do
      expect(subject).to have_error_for('a', :too_short)
      expect(subject).to have_error_for('abcde', :too_long)
    end
  end

  context 'range' do
    let(:params) do
      { range: 2..4 }
    end

    it 'does not validate a blank value' do
      expect(subject).to be_valid_for(nil)
      expect(subject).to be_valid_for('')
    end

    it 'passes if the length is within the limits' do
      expect(subject).to be_valid_for('ab')
      expect(subject).to be_valid_for('abcd')
    end

    it 'fails if the length is outside the limits' do
      expect(subject).to have_error_for('a', :too_short)
      expect(subject).to have_error_for('abcde', :too_long)
    end
  end

  context 'exact' do
    let(:params) do
      { exact: 3 }
    end

    it 'does not validate a blank value' do
      expect(subject).to be_valid_for(nil)
      expect(subject).to be_valid_for('')
    end

    it 'passes if the length matches' do
      expect(subject).to be_valid_for('abc')
    end

    it 'fails if the length does not match' do
      expect(subject).to have_error_for('ab', :too_short)
      expect(subject).to have_error_for('abcd', :too_long)
    end
  end
end
