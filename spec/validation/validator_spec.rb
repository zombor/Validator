require 'spec_helper'
require 'validation/validator'
require 'ostruct'

describe Validation::Validator do
  it 'accepts a plain ruby object' do
    validator = Validation::Validator.new(OpenStruct.new)
  end

  context :rules do
    let(:data_object) { OpenStruct.new(:id => 1, :email => 'foo@bar.com') }
    let(:rule_klass) { Validation::Rule::NotEmpty }

    subject { Validation::Validator.new(data_object) }

    it 'accepts a rule name' do
      subject.rule(:email, :not_empty)

      expect(
        subject.instance_variable_get(:@rules)[:email].map(&:class)
      ).to eq([Validation::Rule::NotEmpty])
    end

    it 'accepts a rule class' do
      subject.rule(:email, rule_klass)

      expect(
        subject.instance_variable_get(:@rules)[:email].map(&:class)
      ).to eq([rule_klass])
    end

    it 'accepts multiple rules for the same field' do
      stub_const("Validation::Rule::NotEmpty", not_empty_class = Class.new)
      stub_const("Validation::Rule::Length", length_class = Class.new)
      subject.rule(:email, [:not_empty, :length])

      expect(
        subject.instance_variable_get(:@rules)[:email].map(&:class)
      ).to eq([not_empty_class, length_class])
    end

    it 'accepts rules with name + parameters' do
      rule = double
      expect(Validation::Rule::Length).to receive(:new).with({:maximum => 5, :minimum => 3}).and_return(rule)
      subject.rule(:email, :length => {:maximum => 5, :minimum => 3})

      expect(subject.instance_variable_get(:@rules)[:email]).to eq([rule])
    end

    it 'accepts rules with class + parameters' do
      rule_class = Class.new
      rule = double
      expect(rule_class).to receive(:new).with({:maximum => 5, :minimum => 3}).and_return(rule)
      subject.rule(:email, rule_class => {:maximum => 5, :minimum => 3})

      expect(subject.instance_variable_get(:@rules)[:email]).to eq([rule])
    end

    it 'does something with invalid rules' do
      expect { subject.rule(:email, :foobar) }.to raise_error(Validation::InvalidRule)
    end

    context 'sends the data object to the rule' do
      before :each do
        length = double
        expect(Validation::Rule::Length).to receive(:new).with({:maximum => 5, :minimum => 3}).and_return(length)

        not_empty = double
        expect(not_empty).to receive(:obj=).with(data_object)
        expect(Validation::Rule::NotEmpty).to receive(:new).and_return(not_empty)
      end

      it :single_rule do
        subject.rule(:email, :not_empty)
        subject.rule(:email, :length => {:minimum => 3, :maximum => 5})
      end

      it :multiple_rules do
        subject.rule(:email, [:not_empty, :length => {:minimum => 3, :maximum => 5}])
      end
    end

    it 'returns self so rules can be chained' do
      expect do
        subject
          .rule(:email, :not_empty)
          .rule(:email, :length => {:minimum => 3, :maximum => 5})
      end.not_to raise_error
    end

    it 'returns self so rules can be chained' do
      expect do
        subject
          .rule(:email, :not_empty)
          .rule(:email, :length => {:minimum => 3, :maximum => 5})
      end.to_not raise_error
    end
  end

  context :valid? do
    subject { Validation::Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com')) }

    context :true do
      before :each do
        rule = double(:rule, :valid_value? => true)
        expect(Validation::Rule::NotEmpty).to receive(:new).and_return(rule)
      end

      it 'returns true when the object is valid' do
        subject.rule(:email, :not_empty)
        expect(subject.valid?).to eq(true)
      end
    end

    context :false do
      before :each do
        rule = double(:rule, :valid_value? => false, :error_key => :not_empty, :params => nil)
        expect(Validation::Rule::NotEmpty).to receive(:new).and_return(rule)
      end

      it 'returns false when the object is not valid' do
        subject.rule(:email, :not_empty)
        expect(subject.valid?).to eq(false)
      end
    end

    context 'invalid rule key' do
      before :each do
        rule = double(:rule, :valid_value? => false)
        expect(Validation::Rule::NotEmpty).to receive(:new).and_return(rule)
      end

      it 'raises a descriptive error if a rule exists for an invalid object key' do
        subject.rule(:foobar, :not_empty)
        expect { subject.valid? }.to raise_error(
          Validation::InvalidKey,
          "cannot validate non-existent field 'foobar'"
        )
      end
    end

    context 'invalid rule' do
      before :each do
        rule = double(:rule, :valid_value? => false)
      end

      it 'raises a descriptive error if an invalid rule is attempted' do
        expect {
          subject.rule(:foobar, :invalid_rule)
        }.to raise_error(
          Validation::InvalidRule,
          "uninitialized constant Validation::Rule::InvalidRule"
        )
      end
    end
  end

  context :errors do
    subject { Validation::Validator.new(OpenStruct.new(:id => 1, :email => 'foo@bar.com', :foobar => '')) }

    it 'has no errors when the object is valid' do
      rule = double(:rule, :valid_value? => true, :error_key => :not_empty)
      expect(Validation::Rule::NotEmpty).to receive(:new).and_return(rule)

      subject.rule(:foobar, :not_empty)
      subject.valid?
      expect(subject.errors).to be_empty
    end

    it 'has errors when the object is invalid' do
      rule = double(:rule, :valid_value? => false, :error_key => :not_empty, :params => nil)
      expect(Validation::Rule::NotEmpty).to receive(:new).and_return(rule)

      subject.rule(:foobar, :not_empty)
      subject.valid?
      expect(subject.errors).to eq(:foobar => { :rule => :not_empty, :params => nil })
    end

    it 'shows the first error when there are multiple errors' do
      not_empty = double(:not_empty, :valid_value? => false, :error_key => :not_empty, :params => nil)
      expect(Validation::Rule::NotEmpty).to receive(:new).and_return(not_empty)
      length = double(:length, :valid_value? => false, :error_key => :length)
      expect(Validation::Rule::Length).to receive(:new).and_return(length)

      subject.rule(:foobar, :not_empty)
      subject.rule(:foobar, :length)
      subject.valid?
      expect(subject.errors).to eq(:foobar => { :rule => :not_empty, :params => nil })
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
