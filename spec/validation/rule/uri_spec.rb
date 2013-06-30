require 'ostruct'
require 'validation/rule/uri'

describe Validation::Rule::URI do
  subject { described_class.new }

  it 'has an error key' do
    subject.error_key.should == :uri
  end

  it 'passes when given a valid uri' do
    subject.valid_value?('http://uri.com').should be_true
  end

  it 'has params' do
    subject.params.should == {:required_elements => [:host]}
  end

  it 'fails when given an invalid uri' do
    subject.valid_value?('foo:/%urim').should be_false
  end

  context "part validation" do
    it 'fails to validate when given a uri without a host' do
      subject.valid_value?('http:foo@').should be_false
    end

    it 'fails to validate when given a uri without a scheme' do
      described_class.new([:host, :scheme])
      subject.valid_value?('foo.com').should be_false
    end
  end
end
