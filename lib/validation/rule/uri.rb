module Validation
  module Rule
    class URI
      def initialize(parts=[:host])
        @required_parts = parts
      end

      def error_key
        :uri
      end

      def params
        {:required_elements => @required_parts}
      end

      def valid_value?(uri_string)
        begin
          uri = URI(uri_string)
          @required_parts.each do |part|
            if uri.send(part).nil? || uri.send(part).empty?
              return false
            end
          end
          true
        rescue ::URI::InvalidURIError => e
          return false
        end
      end
    end
  end
end
