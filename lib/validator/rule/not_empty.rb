class Validator
  module Rule
    class NotEmpty
      def valid_value?(value)
        ! (value.nil? || value.empty?)
      end
    end
  end
end
