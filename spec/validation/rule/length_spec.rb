require 'spec_helper'
require 'validation/rule/length'

describe Validation::Rule::Length do
  subject { Validation::Rule::Length }

  it 'has an error key' do
    expect(subject.new('foo').error_key).to eq(:length)
  end

  it 'returns its parameters' do
    rule = subject.new(:minimum => 5)
    expect(rule.params).to eq(:minimum => 5)
  end

  context :minimum do
    let(:rule) { subject.new(:minimum => 5) }

    it 'does not allow nil' do
      expect(rule.valid_value?(nil)).to eq(false)
    end

    it 'is valid' do
      expect(rule.valid_value?('foobarbar')).to eq(true)
    end

    it 'is invalid' do
      expect(rule.valid_value?('foo')).to eq(false)
    end
  end

  context :maximum do
    let(:rule) { subject.new(:maximum => 5) }

    it 'allows nil' do
      expect(rule.valid_value?(nil)).to eq(true)
    end

    it 'is valid' do
      expect(rule.valid_value?('foo')).to eq(true)
    end

    it 'is invalid' do
      expect(rule.valid_value?('foobarbar')).to eq(false)
    end
  end

  context :exact do
    let(:rule) { subject.new(:exact => 5) }

    it 'does not allow nil' do
      expect(rule.valid_value?(nil)).to eq(false)
    end

    it 'is valid' do
      expect(rule.valid_value?('fooba')).to eq(true)
    end

    it 'is valid' do
      expect(rule.valid_value?('foobar')).to eq(false)
    end
  end
end
