require 'spec_helper'
require 'validation/rule/phone'

describe Validation::Rule::Phone do
  subject { Validation::Rule::Phone }

  it 'has an error key' do
    subject.new.error_key.should == :phone
  end

  it 'defaults to america format' do
    subject.new.params.should == {:format => :america}
  end

  context :america do
    let(:rule) { subject.new }
    it 'is valid' do
      [
        '1234567890',
        '11234567890'
      ].each do |phone|
        rule.valid_value?(phone).should be_true
      end
    end

    it 'is invalid' do
      [
        'asdfghjklp',
        '123456789',
        '123456789012'
      ].each do |phone|
        rule.valid_value?(phone).should be_false
      end
    end
  end
end
