module Validation
  module Rule
    class Custom
      include Rule

      rule_id :custom

      def initialize(field, options = {})
        raise ArgumentError, "block required" unless options[:block].is_a?(Proc)
        super
      end

      def validate(value, context)
        options[:block].call(value, context)
      end
    end
  end
end
