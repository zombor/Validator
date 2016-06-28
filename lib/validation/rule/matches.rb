module Validation
  module Rule
    class Matches
      include Rule

      rule_id :matches

      def validate(value, context)
        other_field = options[:field]
        other_value = context.object.send(other_field)
        context.errors << :mismatch unless value == other_value
      end
    end
  end
end
