module Validation
  module Rule
    # Phone rule
    class Phone
      # params can be any of the following:
      #
      #  - :format - the phone number format
      #
      #  Example:
      #
      #  {:format => :america}
      def initialize(params = {:format => :america})
        @params = params
      end

      # returns the params given in the constructor
      def params
        @params
      end

      # determines if value is valid according to the constructor params
      def valid_value?(value)
        send(@params[:format], value)
      end

      def error_key
        :phone
      end

      protected

      def america(value)
        digits = value.gsub(/\D/, '').split(//)

        digits.length == 10 || digits.length == 11
      end
    end
  end
end
