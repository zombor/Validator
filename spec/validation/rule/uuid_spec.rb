require 'ostruct'
require 'validation/rule/uuid'

describe Validation::Rule::UUID do
  params = { :version => 'v4' }
  subject { described_class.new(params) }

  it 'has params' do
    subject.params.should == params
  end

  it 'has an error key' do
    subject.error_key.should == :uuid
  end

  it 'passes when given a valid uuid' do
    subject.valid_value?("05369729-3e2d-4cc1-88ea-c7ad8665a5da").should be_true
  end

  it 'fails when given an invalid uuid' do
    subject.valid_value?('not-a-uuid').should be_false
  end

  it 'fails when given a blank string' do
    subject.valid_value?('').should be_false
  end

  it 'fails when given a non-string' do
    subject.valid_value?(5).should be_false
  end

  it 'fails when given an unknown uuid version' do
    params = { :version => 'v5' }
    subject.valid_value?("05369729-3e2d-4cc1-88ea-c7ad8665a5da").should be_false
  end
end
