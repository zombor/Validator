require 'spec_helper'
require 'validation/rule/regular_expression'

describe Validation::Rule::RegularExpression do
  subject { Validation::Rule::RegularExpression }

  it 'has an error key' do
    subject.new('foo').error_key.should == :regular_expression
  end

  it 'returns its parameters' do
    rule = subject.new(:regex => /\A.+\Z/)
    rule.params.should == {:regex => /\A.+\Z/}
  end

  context :regex do
    let(:rule) { subject.new(:regex => /\A[0-9]+\Z/) }
    it 'is valid' do
      rule.valid_value?('0123456789').should be_true
    end

    it 'is invalid' do
      rule.valid_value?('a').should be_false
      rule.valid_value?('2b').should be_false
      rule.valid_value?('c3').should be_false
    end
  end
end
