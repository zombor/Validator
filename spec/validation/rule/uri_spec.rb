require 'ostruct'
require 'validation/rule/uri'

describe Validation::Rule::URI do
  subject { described_class.new }

  it 'has an error key' do
    expect(subject.error_key).to eq(:uri)
  end

  it 'passes when given a valid uri' do
    expect(subject.valid_value?('http://uri.com')).to eq(true)
  end

  it 'has params' do
    expect(subject.params).to eq(:required_elements => [:host])
  end

  it 'passes with nil' do
    expect(subject.valid_value?(nil)).to eq(true)
  end

  it 'fails when given an invalid uri' do
    expect(subject.valid_value?('foo:/%urim')).to eq(false)
  end

  context "part validation" do
    it 'fails to validate when given a uri without a host' do
      expect(subject.valid_value?('http:foo@')).to eq(false)
    end

    it 'fails to validate when given a uri without a scheme' do
      described_class.new([:host, :scheme])
      expect(subject.valid_value?('foo.com')).to eq(false)
    end
  end
end
