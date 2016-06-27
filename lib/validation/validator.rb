module Validation
  module Rules
    # A hash of rules for this object
    def rules
      @rules ||= {}
    end

    # A hash of errors for this object
    def errors
      @errors ||= {}
    end

    # Define a rule for this object
    #
    # The rule parameter can be one of the following:
    #
    # * a symbol that matches to a class in the Validation::Rule namespace
    #  * e.g. rule(:field, :not_empty)
    # * a hash containing the rule as the key and it's parameters as the values
    #  * e.g. rule(:field, :length => { :minimum => 3, :maximum => 5 })
    # * an array combining the two previous types
    def rule(field, definition)
      field = field.to_sym
      rules[field] = [] if rules[field].nil?

      begin
        if definition.respond_to?(:each_pair)
          add_parameterized_rules(field, definition)
        elsif definition.respond_to?(:each)
          definition.each do |item|
            if item.respond_to?(:each_pair)
              add_parameterized_rules(field, item)
            else
              add_single_rule(field, item)
            end
          end
        else
          add_single_rule(field, definition)
        end
      rescue NameError => e
        raise InvalidRule.new(e)
      end
      self
    end

    # Determines if this object is valid. When a rule fails for a field,
    # this will stop processing further rules. In this way, you'll only get
    # one error per field
    def valid?
      valid = true

      rules.each_pair do |field, rules|
        if ! @obj.respond_to?(field)
          raise InvalidKey, "cannot validate non-existent field '#{field}'"
        end

        rules.each do |r|
          if ! r.valid_value?(@obj.send(field))
            valid = false
            errors[field] = {:rule => r.error_key, :params => r.params}
            break
          end
        end
      end

      @valid = valid
    end

    protected

    # Adds a single rule to this object
    def add_single_rule(field, key_or_klass, params = nil)
      klass = if key_or_klass.respond_to?(:new)
        key_or_klass
      else
        get_rule_class_by_name(key_or_klass)
      end

      args = [params].compact
      rule = klass.new(*args)
      rule.obj = @obj if rule.respond_to?(:obj=)
      rules[field] << rule
    end

    # Adds a set of parameterized rules to this object
    def add_parameterized_rules(field, rules)
      rules.each_pair do |key, params|
        add_single_rule(field, key, params)
      end
    end

    # Resolves the specified rule name to a rule class
    def get_rule_class_by_name(klass)
      klass = camelize(klass)
      Validation::Rule.const_get(klass)
    rescue NameError => e
      raise InvalidRule.new(e)
    end

    # Converts a symbol to a class name, taken from rails
    def camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }.gsub('/', '::')
    end
  end

  # Validator is a simple ruby validation class. You don't use it directly
  # inside your classes like just about every other ruby validation class out
  # there. I chose to implement it in this way so I didn't automatically
  # pollute the namespace of the objects I wanted to validate.
  #
  # This also solves the problem of validating forms very nicely. Frequently
  # you will have a form that represents many different data objects in your
  # system, and you can pre-validate everything before doing any saving.
  class Validator
    include Validation::Rules

    def initialize(obj)
      @rules = self.class.rules if self.class.is_a?(Validation::Rules)
      @obj = obj
    end
  end

  # InvalidKey is raised if a rule is added to a field that doesn't exist
  class InvalidKey < RuntimeError
  end

  # InvalidRule is raised if a rule is added that doesn't exist
  class InvalidRule < RuntimeError
  end
end
