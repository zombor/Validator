class Validator
  def initialize(obj)
    @obj = obj
    @rules = {}
    @errors = {}
  end

  def rule(field, rule)
    if @rules[field.to_sym].nil?
      @rules[field.to_sym] = []
    end

    begin
      if rule.respond_to?(:each_pair)
        rule.each_pair do |key, value|
          r = Validator::Rule.const_get(camelize(key))
          @rules[field.to_sym] << r.new(value)
        end
      elsif rule.respond_to?(:each)
        rule.each do |r|
          r = Validator::Rule.const_get(camelize(r))
          @rules[field.to_sym] << r.new
        end
      else
        rule = Validator::Rule.const_get(camelize(rule))
        @rules[field.to_sym] << rule.new
      end
    rescue NameError => e
      raise InvalidRule
    end
  end

  def valid?
    valid = true

    @rules.each_pair do |field, rules|
      if ! @obj.respond_to?(field)
        raise InvalidKey
      end

      rules.each do |r|
        if ! r.valid_value?(@obj.send(field))
          valid = false
          @errors[field] = {:rule => r.error_key, :params => r.params}
          break
        end
      end
    end

    @valid = valid
  end

  def errors
    @errors
  end

  protected

  def camelize(term)
    string = term.to_s
    string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    string.gsub(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }.gsub('/', '::')
  end

  class InvalidKey < RuntimeError
  end

  class InvalidRule < RuntimeError
  end
end
