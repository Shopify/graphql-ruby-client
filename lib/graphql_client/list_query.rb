module GraphQL
  module Client
    class ListQuery
      def initialize(parent:, field:, return_type:)
        @root_type = parent.type
        @root_type_name = parent.type.name
        @root_id = parent.id
        @parent = parent
        @field = field
        @return_type = return_type
      end

      def query
        QueryBuilder.list_from_object(
          @root_type,
          @root_id,
          @field,
          @return_type)
      end
    end
  end
end
