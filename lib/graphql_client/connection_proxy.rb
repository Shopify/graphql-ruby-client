module GraphQL
  module Client
    class ConnectionProxy
      include Enumerable

      attr_reader :objects, :parent

      def initialize(field:, parent:, parent_field:, client:, fields: [], data: {}, includes: {})
        @field = field
        @parent = parent
        @parent_field = parent_field
        @client = client
        @schema = @client.schema
        @type = @field.base_type
        @objects = []
        @fields = fields
        @loaded = false
        @data = data
        @includes = includes
      end

      def create(attributes = {})
        type = @type.node_type

        type_name = type.name.dup
        type_name[0] = type_name[0].downcase

        mutation = Query::MutationDocument.new(@client.schema) do |m|
          m.add_field("#{type_name}Create", input: attributes) do |field|
            field.add_field(type_name) do |connection_type|
              connection_type.add_fields(*type.scalar_fields.names)
            end

            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        response = @client.query(mutation)
        attributes = response_object(response).fetch(type_name)

        ObjectProxy.new(field: @field, data: attributes, client: @client)
      end

      def each
        load_page unless @loaded

        @objects.each do |node|
          yield ObjectProxy.new(
            client: @client,
            data: node,
            field: @field,
            includes: @includes,
          )
        end
      end

      def length
        entries.length
      end

      private

      def connection_query(after: nil)
        raise "Connection field \"#{@field.name}\" requires a selection set" if @fields.empty?

        parent_type = if @parent.type.is_a? GraphQLSchema::Types::Connection
          @parent.type.node_type
        else
          @parent.type
        end

        query = Query::QueryDocument.new(@schema)

        args = {}

        if @schema.query_root.fields[parent_type.name.downcase].args.key?('id')
          args[:id] = @parent.id
        end

        connection_args = { first: @client.config.per_page }
        connection_args[:after] = after if after

        query.add_field(parent_type.name.downcase, **args) do |node|
          node.add_connection(@field.name, **connection_args) do |connection|
            connection.add_field('id') if @type.node_type.fields.field? 'id'
            connection.add_fields(*@fields)

            if @includes.any?
              add_includes(connection, @includes)
            end
          end
        end

        query
      end

      def add_includes(connection, includes)
        includes.each do |key, values|
          if connection.resolver_type.fields[key.to_s].connection?
            connection.add_connection(key.to_s, first: 100) do |subconnection|
              values.each do |field|
                if field.is_a? String
                  subconnection.add_field(field)
                else
                  add_includes(subconnection, field)
                end
              end
            end
          else
            connection.add_field(key.to_s) do |subfield|
              values.each do |field|
                if field.is_a? String
                  subfield.add_field(field)
                else
                  add_includes(subfield, field)
                end
              end
            end
          end
        end
      end

      def connection_edges(response_data)
        response_data.dig(*parent.query_path, @field.name, 'edges')
      end

      def fetch_page
        initial_response = @client.query(connection_query)
        edges = connection_edges(initial_response.data)
        @objects += nodes(edges)

        response = initial_response

        while next_page?(response.data)
          cursor = edges.last.fetch('cursor')

          response = @client.query(connection_query(after: cursor))

          edges = connection_edges(response.data)
          @objects += nodes(edges)
        end
      end

      def load_page
        if @data.empty?
          fetch_page
        else
          @objects += nodes(@data['edges'])
        end

        @loaded = true
      end

      def next_page?(response_data)
        response_data.dig(*parent.query_path, @field.name, 'pageInfo', 'hasNextPage')
      end

      def nodes(edges_data)
        edges_data.map { |edge| edge.fetch('node') }
      end

      def response_object(response)
        object = response.data.keys.first
        response.data.fetch(object)
      end
    end
  end
end
