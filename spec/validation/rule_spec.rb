require 'spec_helper'
require 'ostruct'

describe Validation::Rule do
  let(:object) do
    OpenStruct.new(field: 'value')
  end

  let(:rule_class) do
    Class.new do
      include Validation::Rule
      rule_id :baz
    end
  end

  let(:rule) do
    rule_class.new(:field, foo: :bar)
  end

  it 'supports inclusion' do
    expect(rule).to be_a(Validation::Rule)
    expect(rule).to be_respond_to(:rule_id)
  end

  it 'raises exception if rule contains no validation logic' do
    expect { rule.validate }.to raise_error(RuntimeError)
  end

  it 'stores field name' do
    expect(rule.field).to eq(:field)
  end

  context 'rule ID' do
    it 'can be retrieved using class method' do
      expect(rule_class.rule_id).to eq(:baz)
    end

    it 'can be set using class method' do
      rule_class.rule_id :whatever
      expect(rule_class.rule_id).to eq(:whatever)
    end

    it 'can be retrieved using instance method' do
      expect(rule.rule_id).to eq(:baz)
    end
  end

  context 'default options' do
    before(:each) do
      rule_class.default_options(bar: :baz)
    end

    it 'can be retrieved' do
      expect(rule_class.default_options).to eq(bar: :baz)
    end

    it 'can be set' do
      rule_class.default_options(abc: :def)
      expect(rule_class.default_options).to eq(abc: :def)
    end

    it 'are applied when instantiating the rule class' do
      expect(rule.options).to eq(foo: :bar, bar: :baz)
    end

    it 'do not overwrite explicitly passed in options' do
      rule_class.default_options(foo: :abc)
      instance = rule_class.new(:field, foo: :bar)
      expect(instance.options).to eq(foo: :bar)
    end

    it 'support blocks for delayed evaluation' do
      rule_class.default_options do
        { bar: :baz }
      end
      expect(rule_class.new(:field).options).to eq(bar: :baz)
    end
  end
end
