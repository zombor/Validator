require 'spec_helper'
require 'validation/rule/length'

describe Validation::Rule::Length do
  subject { Validation::Rule::Length }

  it 'has an error key' do
    subject.new('foo').error_key.should == :length
  end

  it 'returns it\'s parameters' do
    rule = subject.new(:minimum => 5)
    rule.params.should == {:minimum => 5}
  end

  context :minimum do
    let(:rule) { subject.new(:minimum => 5) }

    it 'does not allow nil' do
      rule.valid_value?(nil).should be_false
    end

    it 'is valid' do
      rule.valid_value?('foobarbar').should be_true
    end

    it 'is invalid' do
      rule.valid_value?('foo').should be_false
    end
  end

  context :maximum do
    let(:rule) { subject.new(:maximum => 5) }

    it 'allows nil' do
      rule.valid_value?(nil).should be_true
    end

    it 'is valid' do
      rule.valid_value?('foo').should be_true
    end

    it 'is invalid' do
      rule.valid_value?('foobarbar').should be_false
    end
  end

  context :exact do
    let(:rule) { subject.new(:exact => 5) }

    it 'does not allow nil' do
      rule.valid_value?(nil).should be_false
    end

    it 'is valid' do
      rule.valid_value?('fooba').should be_true
    end

    it 'is valid' do
      rule.valid_value?('foobar').should be_false
    end
  end
end
