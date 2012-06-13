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
end
