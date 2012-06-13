require 'spec_helper'
require 'validator/rule/length'

describe Validator::Rule::Length do
  subject { Validator::Rule::Length }

  it 'has an error key' do
    subject.new('foo').error_key.should == :length
  end

  context :minimum do
    let(:rule) { subject.new(:minimum => 5) }
    it 'is valid' do
      rule.valid_value?('foobarbar').should be_true
    end

    it 'is invalid' do
      rule.valid_value?('foo').should be_false
    end
  end

  context :maximum do
    let(:rule) { subject.new(:maximum => 5) }
    it 'is valid' do
      rule.valid_value?('foo').should be_true
    end

    it 'is invalid' do
      rule.valid_value?('foobarbar').should be_false
    end
  end

  context :exact do
    let(:rule) { subject.new(:exact => 5) }

    it 'is valid' do
      rule.valid_value?('fooba').should be_true
    end

    it 'is valid' do
      rule.valid_value?('foobar').should be_false
    end
  end
end
