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
        @params.each_pair do |key, param|
          return false if key == :minimum && (value.nil? || value.length < param)
          return false if key == :maximum && !value.nil? && value.length > param
          return false if key == :exact && (value.nil? || value.length != param)
        end

        true
      end

      def error_key
        :length
      end
    end
  end
end
