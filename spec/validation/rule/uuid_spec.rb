require 'spec_helper'

describe Validation::Rule::Uuid do
  subject do
    described_class.new(:field, params)
  end

  let(:params) { Hash.new }

  it 'sets rule ID' do
    expect(described_class.rule_id).to eq(:uuid)
  end

  it 'does not validate a blank value' do
    expect(subject).to be_valid_for(nil)
    expect(subject).to be_valid_for('')
  end

  it 'defaults to any valid uuid' do
    expect(subject.options[:version]).to eq(:any)
  end

  context 'any valid uuid' do
    let(:params) do
      { format: :any }
    end

    it 'passes if the value is a valid uuid' do
      expect(subject).to be_valid_for("05369729-3e2d-1cc1-88ea-c7ad8665a5da")
    end

    it 'fails if the value is not a valid uuid' do
      expect(subject).to have_error_for("not-a-uuid", :invalid)
      expect(subject).to have_error_for(1337, :invalid)
      expect(subject).to have_error_for(['arr', 'ay'], :invalid)
    end
  end

  context 'version 4' do
    let(:params) do
      { version: :v4 }
    end

    it 'passes when given a valid v4 uuid' do
      expect(subject).to be_valid_for("05369729-3e2d-4cc1-88ea-c7ad8665a5da")
    end

    it 'fails when version does not match' do
      expect(subject).to have_error_for("05369729-3e2d-5cc1-88ea-c7ad8665a5da", :invalid)
    end
  end

  context 'version 5' do
    let(:params) do
      { version: :v5 }
    end

    it 'passes when given a valid v4 uuid' do
      expect(subject).to be_valid_for("05369729-3e2d-5cc1-88ea-c7ad8665a5da")
    end

    it 'fails when version does not match' do
      expect(subject).to have_error_for("05369729-3e2d-4cc1-88ea-c7ad8665a5da", :invalid)
    end
  end

  context 'unsupported version' do
    let(:params) do
      { version: :invalid }
    end

    it 'raises exception' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
