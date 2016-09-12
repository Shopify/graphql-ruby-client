module GraphQL
  module Client
    class QueryBuilder
      BLACKLISTED_FIELDS = %w(analyticsToken)

      def initialize(schema)
        @schema = schema
      end

      def for_field(field)
        type = field.base_type

        query = Query::QueryOperation.new(@schema) do |q|
          q.add_field(field.name) do |query_field|
            scalar_field_names = type.scalar_fields.names - BLACKLISTED_FIELDS
            query_field.add_fields(*scalar_field_names)
          end
        end

        query.to_query
      end

      def connection_from_object(root_type, root_id, field, after: nil, per_page:)
        if root_type.is_a? GraphQLSchema::Types::Connection
          root_type = root_type.node_type
        end

        return_type = field.base_type.edges.base_type.node.base_type # Good god
        scalars = return_type.fields.scalars

        query = Query::QueryOperation.new(@schema)

        args = {}

        if root_id && @schema.query_root.fields[root_type.name.downcase].args.key?('id')
          args['id'] = root_id
        end

        connection_args = { first: per_page }
        connection_args[:after] = after if after

        query.add_field(root_type.name.downcase, args) do |node|
          node.add_connection(field.name, connection_args) do |connection|
            connection.add_fields(*scalars.names)
          end
        end

        query.to_query
      end
    end
  end
end
