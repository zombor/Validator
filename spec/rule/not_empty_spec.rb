require 'validator/rule/not_empty'

describe Validator::Rule::NotEmpty do
  it 'passes when a value exists' do
    subject.valid_value?('foo').should be_true
  end

  it 'fails when a value does not exist' do
    ['', nil].each do |value|
      subject.valid_value?(value).should be_false
    end
  end

  it 'has an error key' do
    subject.error_key.should == :not_empty
  end

  it 'returns it\'s parameters' do
    subject.params.should == {}
  end
end
