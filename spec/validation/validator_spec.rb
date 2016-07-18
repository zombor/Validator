require 'spec_helper'
require 'ostruct'

describe Validation::Validator do
  matcher :have_rule do |field, klass, options|
    match do |subject|
      subject = subject.class if subject.is_a?(Validation::Validator)
      subject.rules.any? { |rule|
        rule.field == field && rule.is_a?(klass) &&
          (!options || rule.options == options)
      }
    end
  end

  let(:object) do
    OpenStruct.new(
      name: "John Doe",
      email: "john.doe@sittercity.com",
      password: "123456",
      birth_year: 1980,
      created_at: Time.new(2016, 1, 1, 12, 0, 0)
    )
  end

  let(:validator_class) do
    Class.new do
      include Validation::Validator

      rule :name, :not_empty
      rule :email, :not_empty, :email
      rule :password, :not_empty, :length => { :minimum => 6 }
      rule :birth_year do |value, context|
        context.errors << :not_past if value > Date.today.year
      end
    end
  end

  let(:validator) do
    validator_class.new(object)
  end

  it 'works with inclusion' do
    expect(validator).to be_a(Validation::Validator)
    expect(validator).to have_rule(:name, Validation::Rule::NotEmpty)
  end

  it 'works with inline definition' do
    klass = Validation::Validator.define do
      rule :name, :not_empty
      rule :email, :not_empty, :email
    end
    validator = klass.new(object)
    expect(validator).to be_a(Validation::Validator)
    expect(validator).to have_rule(:name, Validation::Rule::NotEmpty)
  end

  it 'accepts a plain ruby object' do
    object = OpenStruct.new
    validator = validator_class.new(object)
    expect(validator.object).to eq(object)
  end

  context 'rule definition' do
    subject { validator_class }

    let(:custom_rule) do
      Class.new do
        include Validation::Rule
        rule_id :test_rule
      end
    end

    it 'accepts a symbol as rule' do
      subject.rule(:field, :not_empty)
      expect(subject).to have_rule(:field, Validation::Rule::NotEmpty)
    end

    it 'accepts a class as rule' do
      subject.rule(:field, custom_rule)
      expect(subject).to have_rule(:field, custom_rule)
    end

    it 'accepts multiple rules for the same field' do
      subject.rule(:field, :email, custom_rule)
      expect(subject).to have_rule(:field, Validation::Rule::Email)
      expect(subject).to have_rule(:field, custom_rule)
    end

    it 'accepts a named rule with parameters' do
      subject.rule(:field, :length => { :minimum => 3, :maximum => 5 })
      expect(subject).to have_rule(:field, Validation::Rule::Length, :minimum => 3, :maximum => 5)
    end

    it 'accepts a rule class with parameters' do
      subject.rule(:field, custom_rule => { :para => :meters })
      expect(subject).to have_rule(:field, custom_rule, :para => :meters)
    end

    it 'accepts multiple parameterized rules' do
      subject.rule(:field, :length => { :minimum => 3 }, :phone => { :format => :usa })
      expect(subject).to have_rule(:field, Validation::Rule::Length, :minimum => 3)
      expect(subject).to have_rule(:field, Validation::Rule::Phone, :format => :usa)
    end

    it 'accepts a mixture of parameterized and non-parameterized rules' do
      subject.rule(:field, :not_empty, :length => { :minimum => 3 })
      expect(subject).to have_rule(:field, Validation::Rule::NotEmpty)
      expect(subject).to have_rule(:field, Validation::Rule::Length, :minimum => 3)
    end

    it 'accepts a custom rule block' do
      block = Proc.new { }
      subject.rule(:field, &block)
      expect(subject).to have_rule(:field, Validation::Rule::Custom)
      expect(subject.rules_for(:field).first.options[:block]).to eq(block)
    end

    it 'raises exception if named rule is not found' do
      expect { subject.rule(:field, :i_dont_exist) }.to raise_error(Validation::InvalidRule)
    end

    it 'raises exception if rule class does not include Validation::Rule' do
      klass = Class.new
      expect { subject.rule(:field, klass) }.to raise_error(Validation::InvalidRule)
    end

    it 'raises exception if rule class has no rule ID defined' do
      klass = Class.new { include Validation::Rule }
      expect { subject.rule(:field, klass) }.to raise_error(Validation::InvalidRule)
    end

    it 'can be chained' do
      expect {
        subject
          .rule(:email, :not_empty)
          .rule(:email, :length => { :minimum => 3 })
      }.not_to raise_error
    end
  end

  it 'can return all existing rules' do
    expect(validator_class.rules.count).to eq(6)
    expect(validator_class.rules).to be_all { |rule|
      rule.is_a?(Validation::Rule)
    }
  end

  it 'can return existing rules for a specific field' do
    expect(validator_class.rules_for(:email).count).to eq(2)
    expect(validator_class.rules_for(:email)).to be_all { |rule|
      rule.is_a?(Validation::Rule)
    }
  end

  context 'validation' do
    before(:each) do
      validator_class.rules.each do |rule|
        allow(rule).to receive(:validate) { |value, context|
          context.errors << :invalid if value == "invalid value"
        }
      end
    end

    it 'evaluates each rule once' do
      validator_class.rules.each do |rule|
        expect(rule).to receive(:validate).with(
          object.send(rule.field),
          described_class::Context
        )
      end
      validator.validate!
    end

    it 'evaluates rules in the order of their definition' do
      validator.validate!
      expect(validator.results.map(&:field)).to eq(validator_class.rules.map(&:field))
      expect(validator.results.map(&:rule)).to eq(validator_class.rules)
    end

    it 'keeps evaluating all rules even if one fails' do
      object.name = "invalid value"
      object.password = "invalid value"
      validator.validate!
      expect(validator.results.count).to eq(validator_class.rules.count)
      expect(validator.failures.map(&:field).uniq).to eq([:name, :password])
    end

    it 'collects rule evaluation results' do
      validator.validate!
      expect(validator.results.count).to eq(validator_class.rules.count)
      expect(validator.results).to be_all { |result|
        result.is_a?(described_class::Context)
      }
    end

    it 'can return just the failures' do
      object.name = "invalid value"
      validator.validate!
      expect(validator.failures.count).to eq(1)
      expect(validator.failures.first).to be_a(described_class::Context)
      expect(validator.failures.first.field).to eq(:name)
    end

    it 'can return the results for a specific field' do
      validator.validate!
      expect(validator.results_for(:email).count).to eq(validator_class.rules_for(:email).count)
      expect(validator.results_for(:email)).to be_all { |result|
        result.is_a?(described_class::Context)
      }
    end

    it 'returns success if there are no errors' do
      validator.validate!
      expect(validator.valid?).to eq(true)
    end

    it 'returns failure if there are errors' do
      object.password = "invalid value"
      validator.validate!
      expect(validator.valid?).to eq(false)
    end

    it 'keeps a consistent internal state if executed multiple times' do
      object.email = "invalid value"
      validator.validate!
      validator.validate!
      expect(validator.valid?).to eq(false)
      expect(validator.results.count).to eq(validator_class.rules.count)
      expect(validator.failures.count).to eq(validator_class.rules_for(:email).count)

      object.email = "this time it's valid"
      validator.validate!
      expect(validator.valid?).to eq(true)
      expect(validator.results.count).to eq(validator_class.rules.count)
      expect(validator.failures).to be_empty
    end

    it 'supports manual reset' do
      object.email = "invalid value"
      validator.validate!
      expect(validator.results).not_to be_empty
      validator.reset
      expect(validator.results).to be_empty
    end

    it 'raises exception if a rule exists for a non-existent field' do
      validator_class.rule(:foo_bar, :not_empty)
      expect { validator.validate! }.to raise_error(
        Validation::InvalidKey,
        "cannot validate non-existent field 'foo_bar'"
      )
    end

    it 'returns aggregated error hash' do
      object.birth_year = "invalid value"
      object.email = "invalid value"
      validator.validate!
      expect(validator.errors).to eq(
        birth_year: [
          described_class::Error.new(:custom, :invalid)
        ],
        email: [
          described_class::Error.new(:not_empty, :invalid),
          described_class::Error.new(:email, :invalid)
        ]
      )
    end
  end
end