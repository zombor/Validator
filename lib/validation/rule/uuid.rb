module Validation
  # UUID rule
  module Rule
    class Uuid
      class UnknownVersion < StandardError; end
      # params can be any of the folowing:
      #
      # - :version - v4
      #              v5
      #              uuid (Any valid uuid)
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

      VERSION_REGEX = {
        'uuid' => /^[0-9A-F]{8}-[0-9A-F]{4}-[1-5][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
        'v4'   => /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
        'v5'   => /^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
      }

      def uuid_regex
        VERSION_REGEX.fetch(params[:version]) { raise UnknownVersion }
      end

    end
  end
end
