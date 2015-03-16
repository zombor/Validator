module Validation
  # UUID rule
  module Rule
    class Uuid
      class UnknownVersion < StandardError; end
      # params can be any of the folowing:
      #
      # - :version - v4 (only supports v4 at this time)
      #
      # Example:
      #
      # {:version => v4}
      def initialize(params)
        @params = params
      end

      def params
        @params
      end

      def valid_value?(value)
        value.nil? || !!uuid_regex.match(value.to_s)
      rescue UnknownVersion
        false
      end

      def error_key
        :uuid
      end

      private

      def uuid_regex
        if params[:version] == 'v4'
          uuid_v4_regex
        else
          raise UnknownVersion
        end
      end

      def uuid_v4_regex
        /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i
      end
    end
  end
end
