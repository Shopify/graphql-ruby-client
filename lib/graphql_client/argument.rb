module GraphQL
  module Client
    class Argument
      attr_reader :name, :description, :type

      def initialize(name, description, type: nil)
        @name = name
        @description = description
        @type = type
      end
    end
  end
end
