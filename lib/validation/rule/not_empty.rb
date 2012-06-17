module Validation
  module Rule
    # Rule for not empty
    class NotEmpty
      # This rule has no params
      def params
        {}
      end

      # Determines if value is empty or not. In this rule, nil is empty
      def valid_value?(value)
        ! (value.nil? || value.empty?)
      end

      # The error key for this field
      def error_key
        :not_empty
      end
    end
  end
end
