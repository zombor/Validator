module Validation
  module Rule
    class Numeric
      include Rule

      rule_id :numeric

      def validate(value, context)
        return if blank?(value)

        minimum = options[:minimum] || (options[:range] && options[:range].min)
        maximum = options[:maximum] || (options[:range] && options[:range].max)
        decimals = options[:decimals].to_i || 0

        if !value.respond_to?(:to_f)
          context.errors << :invalid
        if value.is_a?(String) && !/^[+-]?[0-9]+(\.[0-9]+)?$/.match(value)
          context.errors << :invalid
        else
          value = value.to_f
          context.errors << :invalid if value != value.round(decimals)
          context.errors << :too_small if minimum && value < minimum
          context.errors << :too_large if maximum && value > maximum
        end
      end
    end
  end
end
