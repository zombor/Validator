module Validation
  module Rule
    class NotEmpty
      include Rule

      rule_id :not_empty

      def validate(value, context)
        context.errors << :required if blank?(value)
      end
    end
  end
end
