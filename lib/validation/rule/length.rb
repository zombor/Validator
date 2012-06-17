module Validation
  module Rule
    # Length rule
    class Length
      # params can be any of the following:
      #
      #  - :minimum - at least this many chars
      #  - :maximum - at most this many chars
      #  - :exact - exactly this many chars
      #
      #  Example:
      #
      #  {:minimum => 3, :maximum => 10}
      #  {:exact => 10}
      def initialize(params)
        @params = params
      end

      # returns the params given in the constructor
      def params
        @params
      end

      # determines if value is valid according to the constructor params
      def valid_value?(value)
        valid = true

        @params.each_pair do |key, param|
          valid = false if key == :minimum && value.length < param
          valid = false if key == :maximum && value.length > param
          valid = false if key == :exact && value.length != param
        end

        valid
      end

      def error_key
        :length
      end
    end
  end
end
