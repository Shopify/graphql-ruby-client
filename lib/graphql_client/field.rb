module GraphQL
  module Client
    class Field
      attr_reader :name, :type_name, :required

      def initialize(name, type_name, required)
        @name = name
        @type_name = type_name
        @required = required
      end
    end
  end
end
