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
    #  * e.g. rule(:field, :length => {:minimum => 3, :maximum => 5})
    # * an array combining the two previous types
    def rule(field, rule)
      field = field.to_sym
      if rules[field].nil?
        rules[field] = []
      end

      begin
        if rule.respond_to?(:each_pair)
          add_parameterized_rule(field, rule)
        elsif rule.respond_to?(:each)
          rule.each do |r|
            if r.respond_to?(:each_pair)
              add_parameterized_rule(field, r)
            else
              r = Validation::Rule.const_get(camelize(r)).new
              add_object_to_rule(r)
              rules[field] << r
            end
          end
        else
          rule = Validation::Rule.const_get(camelize(rule)).new
          add_object_to_rule(rule)
          rules[field] << rule
        end
      rescue NameError => e
        raise InvalidRule
      end
    end

    # Determines if this object is valid. When a rule fails for a field,
    # this will stop processing further rules. In this way, you'll only get
    # one error per field
    def valid?
      valid = true

      rules.each_pair do |field, rules|
        if ! @obj.respond_to?(field)
          raise InvalidKey
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

    # Adds a parameterized rule to this object
    def add_parameterized_rule(field, rule)
      rule.each_pair do |key, value|
        r = Validation::Rule.const_get(camelize(key)).new(value)
        add_object_to_rule(r)
        rules[field] << r
      end
    end

    # Adds this validation object to a rule if it can accept it
    def add_object_to_rule(rule)
      if rule.respond_to?(:obj=)
        rule.obj = @obj
      end
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
