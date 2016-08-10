module GraphQL
  module Client
    class IdentifierError < StandardError; end

    class GlobalID
      attr_reader :domain, :model_id, :model_name

      def initialize(full_identifier)
        full_identifier =~ %r{gid:\/\/(.*?)\/(.*?)\/(\d*)}

        raise IdentifierError if Regexp.last_match(3).nil?

        @domain = Regexp.last_match(1)
        @model_name = Regexp.last_match(2)
        @model_id = Regexp.last_match(3)
      end
    end
  end
end
