module Validation
  module Rule
    class URI
      include Rule

      rule_id :uri
      default_options required_parts: [:host]

      def validate(value, context)
        return if blank?(value)

        uri = ::URI.parse(value)

        if options[:required_parts].any? { |part| blank?(uri.send(part)) }
          context.errors << :invalid
        end
      rescue ::URI::InvalidURIError
        context.errors << :invalid
      end
    end
  end
end
