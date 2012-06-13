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
      rule = stub
      Validator::Rule::Length.should_receive(:new).and_return(rule)
      subject.rule(:email, [:not_empty, :length])

      subject.instance_variable_get(:@rules)[:email].map {|rule| rule.class }.should == [
        Validator::Rule::NotEmpty,
        stub.class
      ]
    end

    it 'accepts rules with parameters' do
      rule = stub
      Validator::Rule::Length.should_receive(:new).with({:maximum => 5, :minimum => 3}).and_return(rule)
      subject.rule(:email, :length => {:maximum => 5, :minimum => 3})

      subject.instance_variable_get(:@rules)[:email].should == [rule]
    end

    it 'does something with invalid rules' do
      lambda { subject.rule(:email, :foobar) }.should raise_error(Validator::InvalidRule)
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
        rule = stub('rule', :valid_value? => false, :error_key => :not_empty)
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

  context :errors do
    subject { Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com', :foobar => '')) }

    it 'has no errors when the object is valid' do
      rule = stub('rule', :valid_value? => true, :error_key => :not_empty)
      Validator::Rule::NotEmpty.should_receive(:new).and_return(rule)

      subject.rule(:foobar, :not_empty)
      subject.valid?
      subject.errors.should == {}
    end

    it 'has errors when the object is invalid' do
      rule = stub('rule', :valid_value? => false, :error_key => :not_empty)
      Validator::Rule::NotEmpty.should_receive(:new).and_return(rule)

      subject.rule(:foobar, :not_empty)
      subject.valid?
      subject.errors.should == {:foobar => :not_empty}
    end

    it 'shows the first error when there are multiple errors' do
      not_empty = stub('not_empty', :valid_value? => false, :error_key => :not_empty)
      Validator::Rule::NotEmpty.should_receive(:new).and_return(not_empty)
      length = stub('length', :valid_value? => false, :error_key => :length)
      Validator::Rule::Length.should_receive(:new).and_return(length)

      subject.rule(:foobar, :not_empty)
      subject.rule(:foobar, :length)
      subject.valid?
      subject.errors.should == {:foobar => :not_empty}
    end
  end
end

class Validator
  module Rule
    class Length
    end
    class NotEmpty
    end
  end
end
