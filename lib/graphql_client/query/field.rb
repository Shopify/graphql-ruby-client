module GraphQL
  module Client
    module Query
      module Field
        INVALID_FIELD = Class.new(StandardError)

        def add_connection(connection_name, arguments = {})
          add_field(connection_name, arguments) do |connection|
            connection.add_field('edges') do |edges|
              edges.add_field('cursor')
              edges.add_field('node') do |node|
                yield node
              end
            end

            connection.add_field('pageInfo') do |page_info|
              page_info.add_field('hasNextPage')
            end
          end
        end

        def add_field(field_name, arguments = {})
          field = resolve(field_name)
          query_field = QueryField.new(field, arguments: arguments)
          @query_fields << query_field

          if block_given?
            yield query_field
          else
            query_field
          end
        end

        private

        def resolve(field_name)
          resolver_type.fields.fetch(field_name) do
            raise INVALID_FIELD, "#{field_name} is not a valid field for #{resolver_type}"
          end
        end
      end
    end
  end
end
