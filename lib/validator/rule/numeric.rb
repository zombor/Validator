class Validator
  module Rule
    class Numeric
      def valid_value?(value)
       !!/^[0-9]+$/.match(value.to_s)
      end

      def error_key
        :numeric
      end

      def params
        {}
      end
    end
  end
end
