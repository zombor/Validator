module Validation
  module Rule
    class Regex
      include Rule

      rule_id :regex

      def validate(value, context)
        return if blank?(value)

        context.errors << :invalid unless options[:regex].match(value.to_s)
      end
    end
  end
end
