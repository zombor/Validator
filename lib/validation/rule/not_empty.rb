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
        ! (check_nil(value) || check_empty(value))
      end

      # The error key for this field
      def error_key
        :not_empty
      end

      private

      def check_nil(value)
        if value.respond_to?(:nil?)
          value.nil?
        end
      end

      def check_empty(value)
        if value.respond_to?(:empty?)
          value.empty?
        end
      end
    end
  end
end
