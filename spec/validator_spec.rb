require 'spec_helper'
require 'validator'
require 'ostruct'

describe Validator do
  it 'accepts a plain ruby object' do
    validator = Validator.new(OpenStruct.new)
  end

  context :rules do
    subject { Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com')) }
    it 'accepts a rule' do
      subject.rule(:email, :not_empty)

      subject.instance_variable_get(:@rules)[:email].map {|rule| rule.class }.should  == [Validator::Rule::NotEmpty]
    end

    it 'accepts multiple rules for the same field' do
      subject.rule(:email, [:not_empty, :length])

      subject.instance_variable_get(:@rules)[:email].map {|rule| rule.class }.should == [
        Validator::Rule::NotEmpty,
        Validator::Rule::Length
      ]
    end

    it 'accepts rules with parameters' do
      rule = stub
      Validator::Rule::Length.should_receive(:new).with({:maximum => 5, :minimum => 3}).and_return(rule)
      subject.rule(:email, :length => {:maximum => 5, :minimum => 3})

      subject.instance_variable_get(:@rules)[:email].should == [rule]
    end
  end

  context :valid? do
    subject { Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com')) }

    context :true do
      before :each do
        rule = stub('rule', :valid_value? => true)
        Validator::Rule::NotEmpty.should_receive(:new).and_return(rule)
      end

      it 'returns true when the object is valid' do
        subject.rule(:email, :not_empty)
        subject.valid?.should be_true
      end
    end

    context :false do
      before :each do
        rule = stub('rule', :valid_value? => false)
        Validator::Rule::NotEmpty.should_receive(:new).and_return(rule)
      end

      it 'returns false when the object is not valid' do
        subject.rule(:email, :not_empty)
        subject.valid?.should be_false
      end
    end

    context 'invalid rule key' do
      before :each do
        rule = stub('rule', :valid_value? => false)
        Validator::Rule::NotEmpty.should_receive(:new).and_return(rule)
      end

      it 'raises an error if a rule exists for an invalid object key' do
        subject.rule(:foobar, :not_empty)
        lambda { subject.valid? }.should raise_error(Validator::InvalidKey)
      end
    end
  end
end

class Validator
  module Rule
    class NotEmpty
    end

    class Length
      def initialize(*args)
      end
    end
  end
end
