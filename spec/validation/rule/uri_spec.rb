require 'spec_helper'

describe Validation::Rule::URI do
  subject do
    described_class.new(:field, params)
  end

  let(:params) { Hash.new }

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:uri)
  end

  it 'does not validate a blank value' do
    expect(subject).to be_valid_for(nil)
    expect(subject).to be_valid_for('')
  end

  it 'defaults to require the host part' do
    expect(subject.options[:required_parts]).to eq([:host])
  end

  it 'passes when given a valid url' do
    [
      'http://valid.url',
      'https://also.valid',
      '//and.this/as/well',
      'ftp://this.is/?valid=too'
    ].each do |value|
      expect(subject).to be_valid_for(value)
    end
  end

  it 'fails when given an invalid url' do
    [
      'not-an-url',
      'whats//going\\on//here?',
      'http:://invalid.url',
    ].each do |value|
      expect(subject).to have_error_for(value, :invalid)
    end
  end

  context 'part validation' do
    let(:params) do
      { required_parts: [:host, :query] }
    end

    it 'passes if required parts are present' do
      [
        'http://domain.tld?query=params',
        'http://domain.tld/the/path?query=params',
        'http://domain.tld:1234/?query=params'
      ].each do |value|
        expect(subject).to be_valid_for(value)
      end
    end

    it 'fails if a required part is not present' do
      [
        '/missing.host?query=params',
        'http://missing.query/params'
      ].each do |value|
        expect(subject).to have_error_for(value, :invalid)
      end
    end
  end
end
