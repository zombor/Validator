require 'spec_helper'
require 'validation/validator'
require 'ostruct'

describe Validation::Validator do
  it 'accepts a plain ruby object' do
    validator = Validation::Validator.new(OpenStruct.new)
  end

  context :rules do
    let(:data_object) { OpenStruct.new(:id => 1, :email => 'foo@bar.com') }
    subject { Validation::Validator.new(data_object) }

    it 'accepts a rule' do
      subject.rule(:email, :not_empty)

      subject.instance_variable_get(:@rules)[:email].map {|rule| rule.class }.should  == [Validation::Rule::NotEmpty]
    end

    it 'accepts multiple rules for the same field' do
      not_empty = stub
      Validation::Rule::NotEmpty.should_receive(:new).and_return(not_empty)
      length = stub
      Validation::Rule::Length.should_receive(:new).and_return(length)
      subject.rule(:email, [:not_empty, :length])

      subject.instance_variable_get(:@rules)[:email].map {|rule| rule.class }.should == [
        not_empty.class,
        length.class
      ]
    end

    it 'accepts rules with parameters' do
      rule = stub
      Validation::Rule::Length.should_receive(:new).with({:maximum => 5, :minimum => 3}).and_return(rule)
      subject.rule(:email, :length => {:maximum => 5, :minimum => 3})

      subject.instance_variable_get(:@rules)[:email].should == [rule]
    end

    it 'does something with invalid rules' do
      lambda { subject.rule(:email, :foobar) }.should raise_error(Validation::InvalidRule)
    end

    context 'sends the data object to the rule' do
      before :each do
        length = stub
        Validation::Rule::Length.should_receive(:new).with({:maximum => 5, :minimum => 3}).and_return(length)

        not_empty = stub
        not_empty.should_receive(:obj=).with(data_object)
        Validation::Rule::NotEmpty.should_receive(:new).and_return(not_empty)
      end

      it :single_rule do
        subject.rule(:email, :not_empty)
        subject.rule(:email, :length => {:minimum => 3, :maximum => 5})
      end

      it :multiple_rules do
        subject.rule(:email, [:not_empty, :length => {:minimum => 3, :maximum => 5}])
      end

    end
  end

  context :valid? do
    subject { Validation::Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com')) }

    context :true do
      before :each do
        rule = stub('rule', :valid_value? => true)
        Validation::Rule::NotEmpty.should_receive(:new).and_return(rule)
      end

      it 'returns true when the object is valid' do
        subject.rule(:email, :not_empty)
        subject.valid?.should be_true
      end
    end

    context :false do
      before :each do
        rule = stub('rule', :valid_value? => false, :error_key => :not_empty, :params => nil)
        Validation::Rule::NotEmpty.should_receive(:new).and_return(rule)
      end

      it 'returns false when the object is not valid' do
        subject.rule(:email, :not_empty)
        subject.valid?.should be_false
      end
    end

    context 'invalid rule key' do
      before :each do
        rule = stub('rule', :valid_value? => false)
        Validation::Rule::NotEmpty.should_receive(:new).and_return(rule)
      end

      it 'raises an error if a rule exists for an invalid object key' do
        subject.rule(:foobar, :not_empty)
        lambda { subject.valid? }.should raise_error(Validation::InvalidKey)
      end
    end
  end

  context :errors do
    subject { Validation::Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com', :foobar => '')) }

    it 'has no errors when the object is valid' do
      rule = stub('rule', :valid_value? => true, :error_key => :not_empty)
      Validation::Rule::NotEmpty.should_receive(:new).and_return(rule)

      subject.rule(:foobar, :not_empty)
      subject.valid?
      subject.errors.should == {}
    end

    it 'has errors when the object is invalid' do
      rule = stub('rule', :valid_value? => false, :error_key => :not_empty, :params => nil)
      Validation::Rule::NotEmpty.should_receive(:new).and_return(rule)

      subject.rule(:foobar, :not_empty)
      subject.valid?
      subject.errors.should == {:foobar => {:rule => :not_empty, :params => nil}}
    end

    it 'shows the first error when there are multiple errors' do
      not_empty = stub('not_empty', :valid_value? => false, :error_key => :not_empty, :params => nil)
      Validation::Rule::NotEmpty.should_receive(:new).and_return(not_empty)
      length = stub('length', :valid_value? => false, :error_key => :length)
      Validation::Rule::Length.should_receive(:new).and_return(length)

      subject.rule(:foobar, :not_empty)
      subject.rule(:foobar, :length)
      subject.valid?
      subject.errors.should == {:foobar => {:rule => :not_empty, :params => nil}}
    end
  end

  context :errors_described do
    subject { Validation::Validator.new(OpenStruct.new(:id => 1, :email => '', :foobar => '')) }

    it "describes errors in English" do
      not_empty = stub('not_empty', :valid_value? => false, :error_key => :not_empty, :params => nil)
      Validation::Rule::NotEmpty.should_receive(:new).and_return(not_empty)
      length = stub('length', :valid_value? => false, :error_key => :length, :params => nil)
      Validation::Rule::Length.should_receive(:new).and_return(length)

      subject.rule(:email, :not_empty)
      subject.rule(:foobar, :length)
      subject.valid?
      subject.errors_described.should == 
            "The value of 'email' failed the validation rule 'not_empty'.\n" +
            "The value of 'foobar' failed the validation rule 'length'."
    end
  end

  context :describe_errors do
    
    it "can describe a validation error" do
      errors = {:email=>{:rule=>:not_empty, :params=>{}}}

      actual = Validation::Rules::describe_errors(errors)

      actual.should == "The value of 'email' failed the validation rule 'not_empty'."
    end

    it "can describe a parameterized validation error" do
      errors = {:email=>{:rule=>:length, :params=>{:minimum => 100}}}

      actual = Validation::Rules::describe_errors(errors)

      actual.should == "The value of 'email' failed the validation rule 'length {:minimum=>100}'."
    end

    it "can describe a few validation errors" do
      errors = {
        :email=>{:rule=>:length, :params=>{:minimum => 100}},
        :telephone=>{:rule=>:length, :params=>{:minimum => 8}},
      }

      actual = Validation::Rules::describe_errors(errors)

      actual.should == "The value of 'email' failed the validation rule 'length {:minimum=>100}'.\n" +
                        "The value of 'telephone' failed the validation rule 'length {:minimum=>8}'."
    end

  end

end

module Validation
  module Rule
    class Length
    end
    class NotEmpty
    end
  end
end
