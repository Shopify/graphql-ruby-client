module GraphQL
  module Client
    class ConnectionProxy
      include Enumerable

      attr_reader :arguments, :cursor, :parent

      def initialize(*fields, field:, parent:, client:, data: {}, includes: {}, **arguments)
        @selection_set = fields.map(&:to_s)
        @field = field
        @parent = parent
        @client = client
        @data = data
        @includes = includes
        @schema = @client.schema
        @type = @field.base_type
        @nodes = build_nodes(data.fetch('edges', []))
        @loaded = false
        @arguments = arguments
      end

      def create(attributes = {})
        type = @type.node_type

        type_name = type.name.dup
        type_name[0] = type_name[0].downcase

        mutation_name = "#{type_name}Create"

        mutation = Query::MutationDocument.new(@client.schema) do |m|
          m.add_field(mutation_name, input: attributes) do |field|
            field.add_field(type_name) do |connection_type|
              connection_type.add_fields(*type.scalar_fields.names)
            end

            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        response = @client.query(mutation)
        data = response.data.dig(mutation_name, type_name)

        ObjectProxy.new(field: @field, data: data, client: @client)
      end

      def each(start = 0)
        return to_enum(:each, start) unless block_given?

        Array(@nodes[start..-1]).each do |node|
          yield node
        end

        unless last_page?
          start = [@nodes.size, start].max

          fetch_page

          each(start, &Proc.new)
        end
      end

      def length
        entries.length
      end

      def last_page?
        @data.dig('pageInfo', 'hasNextPage') == false
      end

      def proxy_path
        [].tap do |parents|
          parents << parent.proxy_path if parent
          parents << parent if parent
        end.flatten
      end

      private

      def add_includes(connection, includes = @includes)
        includes.each do |key, values|
          field_name = key.to_s

          if connection.resolver_type.fields[field_name].connection?
            connection.add_connection(
              field_name,
              first: @arguments.fetch(:first, @client.config.per_page)
            ) do |subconnection|
              values.each do |field|
                if field.is_a? String
                  subconnection.add_field(field)
                else
                  add_includes(subconnection, field)
                end
              end
            end
          else
            connection.add_field(field_name) do |subfield|
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

      def build_nodes(edges_data)
        edges_data.map do |edge|
          ObjectProxy.new(
            client: @client,
            data: edge.fetch('node'),
            field: @field,
            includes: @includes,
          )
        end
      end

      def connection_query
        if @selection_set.empty? && @includes.empty?
          raise %q(Connection field "#{@field.name}" requires a selection set)
        end

        query = Query::QueryDocument.new(@schema)

        connection_args = {}.tap do |args|
          args[:first] = @arguments.fetch(:first, @client.config.per_page)
          args[:after] = @cursor if @cursor
          args[:after] = @arguments.fetch(:after) if @arguments.key?(:after)
        end

        query_field = if parent.loaded && parent_with_id?
          # We can shortcut this query and base it off of an already known node object
          query.add_field(parent.field_name, id: parent.id)
        else
          rebuild_query(query)
        end

        query_field.add_connection(@field.name, **connection_args) do |connection|
          connection.add_field('id') if @type.node_type.fields.field? 'id'
          connection.add_fields(*@selection_set)

          add_includes(connection)
        end

        query
      end

      def fetch_page
        @response = @client.query(connection_query)

        @data = @response.data.dig(*parent.query_path, @field.name)
        edges = @data.fetch('edges')
        @nodes += build_nodes(edges)
        @cursor = edges.last.fetch('cursor')

        @loaded = true
      end

      def parent_with_id?
        parent.id && @schema.query_root.fields.fetch(parent.field_name).args.key?('id')
      end

      def rebuild_query(query)
        proxy_path.each do |proxy|
          query = query.add_field(proxy.field.name, proxy.arguments)
        end

        query
      end
    end
  end
end
