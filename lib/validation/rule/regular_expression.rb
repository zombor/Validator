module Validation
  module Rule
    class RegularExpression

      def initialize(params)
        @params = params
      end

      def error_key
        :regular_expression
      end

      def valid_value?(value)
        value.nil? || !!@params[:regex].match(value)
      end

      def params
        @params
      end
    end
  end
end
