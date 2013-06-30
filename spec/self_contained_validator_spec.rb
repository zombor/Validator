require 'spec_helper'
require 'validation'
require 'validation/rule/not_empty'
require 'validation/rule/email'
require 'validation/rule/length'
require 'ostruct'

class SelfContainedValidator < Validation::Validator
  include Validation

  rule :test_mail, :email
  rule :test_string, [:not_empty,
                      :length => { :maximum => 5 }]
end

describe SelfContainedValidator do
  let(:success_data) { OpenStruct.new(:test_mail => 'test@email.com', :test_string => 'test') }
  let(:fail_data)    { OpenStruct.new(:test_mail => 'not an email', :test_string => '') }

  context 'behaves like a validator' do
    subject { SelfContainedValidator.new(success_data) }

    it { should respond_to('valid?') }
    it { should respond_to(:errors) }
  end

  it 'passes validation for correct data' do
    foo = SelfContainedValidator.new(success_data)
    foo.should be_valid
    foo.errors.should be_empty
  end

  it 'fails validation for wrong data' do
    foo = SelfContainedValidator.new(fail_data)
    foo.should_not be_valid
    foo.errors.should include(:test_mail, :test_string)
  end

  context 'when adding new rules' do
    let(:data) { OpenStruct.new(:test_mail => 'test@email.com', :test_string => '') }
    subject { SelfContainedValidator.new(data) }
    before { subject.rule(:test_mail, :length => { :maximum => 3}) }

    it 'keeps the old rules' do
      subject.should_not be_valid
      subject.errors.should include(:test_string)
    end

    it 'validates both old and new rules' do
      subject.should_not be_valid
      subject.errors.should include(:test_mail)
    end
  end
end
