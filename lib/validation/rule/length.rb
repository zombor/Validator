module Validation
  module Rule
    class Length
      include Rule

      rule_id :length

      def validate(value, context)
        return if blank?(value)

        length = value.length
        minimum = options[:exact] || options[:minimum] || (options[:range] && options[:range].min)
        maximum = options[:exact] || options[:maximum] || (options[:range] && options[:range].max)

        context.errors << :too_short if minimum && length < minimum
        context.errors << :too_long if maximum && length > maximum
      end
    end
  end
end
