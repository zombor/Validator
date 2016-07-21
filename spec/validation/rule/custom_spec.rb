require 'spec_helper'

describe Validation::Rule::Custom do
  subject do
    described_class.new(:field, block: Proc.new { |value, context|
      context.errors << :its_bad if value == "bad"
    })
  end

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:custom)
  end

  it 'raises exception if no block is given' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  it 'executes block' do
    expect(subject).to be_valid_for('any value')
    expect(subject).to have_error_for('bad', :its_bad)
  end
end
