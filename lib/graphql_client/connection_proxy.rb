module GraphQL
  module Client
    class ConnectionProxy
      include Enumerable

      def initialize(parent:, parent_field:, client:, field:, fields: [])
        @parent = parent
        @parent_field = parent_field
        @client = client
        @schema = @client.schema
        @field = field
        @type = @field.base_type
        @objects = []
        @fields = fields
        @loaded = false
      end

      def create(attributes = {})
        type = @type.node_type

        type_name = type.name.dup
        type_name[0] = type_name[0].downcase

        mutation = Query::MutationOperation.new(@client.schema) do |q|
          q.add_field("#{type_name}Create", input: attributes) do |field|
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

        ObjectProxy.new(field: @field, attributes: attributes, client: @client)
      end

      def each
        fetch_page unless @loaded

        @objects.each do |node|
          yield ObjectProxy.new(attributes: node, client: @client, field: @field)
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

        query = Query::QueryOperation.new(@schema)

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
          end
        end

        query
      end

      def deep_find(hash, target_key)
        return hash[target_key] if hash.key?(target_key)

        hash.each do |_, value|
          result = deep_find(value, target_key) if value.is_a? Hash
          return result unless result.nil?
        end

        nil
      end

      def fetch_page
        @loaded = true

        initial_response = @client.query(connection_query)
        edges = deep_find(initial_response.data, 'edges')

        response = initial_response
        @objects += edges.map { |edge| edge.fetch('node') }

        while next_page?(response.data)
          cursor = edges.last.fetch('cursor')

          response = @client.query(connection_query(after: cursor))
          edges = deep_find(response.data, 'edges')

          @objects += edges.map { |edge| edge.fetch('node') }
        end
      end

      def next_page?(response_data)
        next_page = deep_find(response_data, 'hasNextPage')
        if next_page.nil?
          false
        else
          next_page
        end
      end

      def response_object(response)
        object = response.data.keys.first
        response.data.fetch(object)
      end
    end
  end
end
