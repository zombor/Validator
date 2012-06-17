module Validation
  module Rule
    # Matches rule
    class Matches
      attr_writer :obj

      # This class should take the field to match with in the constructor:
      #
      # rule = Validation::Rule::Matches(:password)
      # rule.obj = OpenStruct.new(:password => 'foo')
      # rule.valid_value?('foo')
      def initialize(matcher_field)
        @matcher_field = matcher_field
      end

      # The error key for this rule
      def error_key
        :matches
      end

      # Params is the matcher_field given in the constructor
      def params
        @matcher_field
      end

      # Determines if value matches the field given in the constructor
      def valid_value?(value)
        matcher_value = @obj.send(@matcher_field)
        matcher_value == value
      end
    end
  end
end
