module Validation
  module Rule
    class Phone
      include Rule

      rule_id :phone
      default_options format: :usa

      def validate(value, context)
        return if blank?(value)

        context.errors << :invalid unless send(options[:format], value)
      end

      protected

      def usa(value)
        digits = value.gsub(/\D/, '').split(//)
        digits.length == 10 || digits.length == 11
      end
    end
  end
end
