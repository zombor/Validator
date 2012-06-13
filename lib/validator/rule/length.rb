class Validator
  module Rule
    class Length
      def initialize(params)
        @params = params
      end

      def valid_value?(value)
        valid = true

        @params.each_pair do |key, param|
          valid = false if key == :minimum && value.length < param
          valid = false if key == :maximum && value.length > param
          valid = false if key == :exact && value.length != param
        end

        valid
      end
    end
  end
end
