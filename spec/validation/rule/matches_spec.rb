require 'spec_helper'
require 'ostruct'

describe Validation::Rule::Matches do
  subject do
    described_class.new(:field, field: :other)
  end

  let(:object) do
    OpenStruct.new(other: 'correct value')
  end

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:matches)
  end

  it 'passes if values match' do
    expect(subject).to be_valid_for('correct value', object)
  end

  it 'fails if values do not match' do
    expect(subject).to have_error_for('incorrect value', :mismatch, object)
    expect(subject).to have_error_for(nil, :mismatch, object)
  end
end
