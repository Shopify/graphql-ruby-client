module GraphQL
  module Client
    class QueryBuilder
      BLACKLISTED_FIELDS = %w(analyticsToken)

      def initialize(schema)
        @schema = schema
      end

      def for_field(field, fields:)
        type = field.base_type

        query = Query::QueryOperation.new(@schema) do |q|
          q.add_field(field.name) do |query_field|
            selection_set = fields - BLACKLISTED_FIELDS
            query_field.add_fields(*selection_set)
          end
        end

        query.to_query
      end

      def connection_from_object(parent, field, fields:, after: nil, per_page:)
        raise "Connection field \"#{field.name}\" requires a selection set" if fields.empty?
        parent_type = if parent.type.is_a? GraphQLSchema::Types::Connection
          parent.type.node_type
        else
          parent.type
        end

        return_type = field.base_type.edges.base_type.node.base_type # Good god
        scalars = return_type.fields.scalars

        query = Query::QueryOperation.new(@schema)

        args = {}

        if @schema.query_root.fields[parent_type.name.downcase].args.key?('id')
          args['id'] = parent.id
        end

        connection_args = { first: per_page }
        connection_args[:after] = after if after

        query.add_field(parent_type.name.downcase, args) do |node|
          node.add_connection(field.name, connection_args) do |connection|
            connection.add_fields(*fields)
          end
        end

        query.to_query
      end
    end
  end
end
