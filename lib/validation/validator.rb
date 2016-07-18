module Validation
  module Validator
    attr_reader :object, :results

    def initialize(object)
      raise ArgumentError, "cannot validate nil" if object.nil?
      @object = object
      @results = []
    end

    def validate!
      reset

      self.class.rules.each do |rule|
        if !object.respond_to?(rule.field)
          raise InvalidKey, "cannot validate non-existent field '#{rule.field}'"
        end

        context = Context.new(rule, object)
        rule.validate(context.value, context)

        results << context
      end

      self
    end

    def valid?
      validate! unless results.any?
      !errors.any?
    end

    def failures
      results.select do |context|
        context.errors.any?
      end
    end

    def results_for(field)
      results.select do |result|
        result.field == field
      end
    end

    Error = Struct.new(:rule, :error)

    def errors
      list = {}
      failures.each do |context|
        list[context.rule.field] ||= []
        context.errors.each do |error|
          list[context.rule.field] << Error.new(context.rule.rule_id, error)
        end
      end
      list
    end

    def reset
      @results = []
    end

    def self.define(&block)
      raise ArgumentError, "block required" unless block_given?
      klass = Class.new
      klass.send(:include, self)
      klass.instance_eval(&block)
      klass
    end

    private

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validate(object)
        instance = self.new(object)
        instance.validate!
      end

      def rules
        parent = respond_to?(:superclass) && superclass.respond_to?(:rules) ? superclass.rules : []
        parent + (@rules || [])
      end

      def rules_for(field)
        rules.select do |rule|
          rule.field == field
        end
      end

      def rule(field, *items, &block)
        if block_given?
          raise "cannot set regular rules and a custom rule on the same line" if items.any?
          add_rule(field, :custom, block: block)
        else
          items.flatten.each do |item|
            if item.respond_to?(:each_pair)
              add_rule_hash(field, item)
            else
              add_rule(field, item)
            end
          end
        end
        self
      end

      private

      def add_rule(field, key_or_klass, options = {})
        klass = if key_or_klass.respond_to?(:new)
          key_or_klass
        else
          get_rule_class_by_name(key_or_klass)
        end

        valid = klass.ancestors.include?(Rule)
        raise InvalidRule, "rule class #{klass.name} does not include Validation::Rule" unless valid
        raise InvalidRule, "rule class #{klass.name} has no rule ID defined" unless klass.rule_id
        rule = klass.new(field, options)

        @rules ||= []
        @rules << rule
      end

      def add_rule_hash(field, hash)
        hash.each_pair do |key, options|
          options = options === true ? {} : options
          add_rule(field, key, options)
        end
      end

      def get_rule_class_by_name(klass)
        klass = camelize(klass)
        Validation::Rule.const_get(klass)
      rescue NameError => e
        raise InvalidRule.new(e)
      end

      def camelize(term)
        string = term.to_s
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }.gsub('/', '::')
      end
    end

    class Context
      attr_reader :rule, :object, :errors

      def initialize(rule, object)
        @rule = rule
        @object = object
        @errors = []
      end

      def field
        rule.field
      end

      def value
        object.send(field)
      end
    end
  end

  class InvalidKey < RuntimeError
  end

  class InvalidRule < RuntimeError
  end
end
