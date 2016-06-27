require 'validation/rule/not_empty'

describe Validation::Rule::NotEmpty do
  it 'passes when a value exists' do
    expect(subject.valid_value?('foo')).to eq(true)
  end

  it 'fails when a value does not exist' do
    ['', nil].each do |value|
      expect(subject.valid_value?(value)).to eq(false)
    end
  end

  it 'has an error key' do
    expect(subject.error_key).to eq(:not_empty)
  end

  it 'returns its parameters' do
    expect(subject.params).to eq({})
  end
end
