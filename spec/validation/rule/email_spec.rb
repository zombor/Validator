require 'spec_helper'

describe Validation::Rule::Email do
  subject do
    described_class.new(:field)
  end

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:email)
  end

  it 'does not validate a blank value' do
    expect(subject).to be_valid_for(nil)
    expect(subject).to be_valid_for('')
  end

  it 'passes with a valid email' do
    expect(subject).to be_valid_for('user@domain.com')
  end

  it 'fails with an invalid email' do
    ['bad-email', 'bad@email', 'b\4d@email.com'].each do |value|
      expect(subject).to have_error_for(value, :invalid)
    end
  end
end
