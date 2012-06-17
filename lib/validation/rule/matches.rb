module Validation
  module Rule
    class Matches
      attr_writer :obj

      def initialize(matcher_field)
        @matcher_field = matcher_field
      end

      def error_key
        :matches
      end

      def params
        @matcher_field
      end

      def valid_value?(value)
        matcher_value = @obj.send(@matcher_field)
        matcher_value == value
      end
    end
  end
end
