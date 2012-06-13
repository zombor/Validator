class Validator
  module Rule
    class NotEmpty
      def valid_value?(value)
        ! (value.nil? || value.empty?)
      end

      def error_key
        :not_empty
      end
    end
  end
end
