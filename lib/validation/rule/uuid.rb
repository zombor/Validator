module Validation
  module Rule
    class Uuid
      include Rule

      rule_id :uuid
      default_options version: :any

      def initialize(field, options = {})
        version = options[:version]
        raise UnknownVersion, "version '#{version}' not supported" unless VERSION_REGEX[version.to_sym]
        super
      end

      def validate(value, context)
        return if blank?(value)

        regex = VERSION_REGEX.fetch(options[:version].to_sym)
        context.errors << :invalid unless regex.match(value.to_s)
      end

      private

      VERSION_REGEX = {
        any: /^[0-9A-F]{8}-[0-9A-F]{4}-[1-5][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
        v4:  /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
        v5:  /^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
      }.freeze

      class UnknownVersion < ArgumentError; end
    end
  end
end
