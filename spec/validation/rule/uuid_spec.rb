require 'ostruct'
require 'validation/rule/uuid'

describe Validation::Rule::Uuid do
  params = { :version => 'uuid' }
  subject { described_class.new(params) }

  it 'has params' do
    expect(subject.params).to eq(params)
  end

  it 'has an error key' do
    expect(subject.error_key).to eq(:uuid)
  end

  it 'passes when given a valid uuid' do
    expect(subject.valid_value?("05369729-3e2d-4cc1-88ea-c7ad8665a5da")).to eq(true)
  end

  it 'passes when given a valid v4 uuid' do
    params = { :version => 'v4' }
    expect(subject.valid_value?("05369729-3e2d-4cc1-88ea-c7ad8665a5da")).to eq(true)
  end

  it 'passes when given a valid v5 uuid' do
    params = { :version => 'v5' }
    expect(subject.valid_value?("05369729-3e2d-5cc1-88ea-c7ad8665a5da")).to eq(true)
  end

  it 'fails when version does not match' do
    params = { :version => 'v4' }
    expect(subject.valid_value?("05369729-3e2d-5cc1-88ea-c7ad8665a5da")).to eq(false)
  end

  it 'fails when given an invalid uuid' do
    expect(subject.valid_value?('not-a-uuid')).to eq(false)
  end

  it 'fails when given a blank string' do
    expect(subject.valid_value?('')).to eq(false)
  end

  it 'fails when given a non-string' do
    expect(subject.valid_value?(5)).to eq(false)
  end

  it 'fails when given an unknown uuid version' do
    params = { :version => 'v6' }
    expect(subject.valid_value?("05369729-3e2d-4cc1-88ea-c7ad8665a5da")).to eq(false)
  end
end
