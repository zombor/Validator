module Validation
  module Rule
    # rule for numeric values
    class Numeric
      # Determines if value is numeric. It can only contain whole numbers
      def valid_value?(value)
       !!/^[0-9]+$/.match(value.to_s)
      end

      # The error key for this rule
      def error_key
        :numeric
      end

      # this rule has no params
      def params
        {}
      end
    end
  end
end
