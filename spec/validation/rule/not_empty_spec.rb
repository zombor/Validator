require 'spec_helper'

describe Validation::Rule::NotEmpty do
  subject do
    described_class.new(:field)
  end

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:not_empty)
  end

  it 'passes if value is not nil or empty' do
    expect(subject).to be_valid_for('some value')
  end

  it 'fails if value is nil or empty' do
    expect(subject).to have_error_for(nil, :required)
    expect(subject).to have_error_for('', :required)
  end
end
