module GraphQL
  module Client
    class ObjectProxy
      attr_reader :type, :attributes

      def initialize(attributes: nil, id: nil, client:, type:)
        if attributes.nil?
          @loaded = false
          @attributes = {}
        else
          @loaded = true
          @attributes = attributes
        end

        @id = id
        @client = client
        @dirty_attributes = Set.new
        @type = type
      end

      def method_missing(name, *arguments)
        field = name.to_s
        return all_from_connection(field) if @type.connection? field
        return all_from_list(field) if @type.list? field

        if field.end_with? '='
          field = field.chomp('=')
          @attributes[field] = arguments.first
          @dirty_attributes.add(field)
        else
          load unless @loaded
          @attributes[field]
        end
      end

      def load
        request = Request.new(client: @client, type: @type)

        if @id
          @attributes = request.find(@id).object
        else
          @attributes = request.simple_find(@type.name).object
        end

        @loaded = true
      end

      def save
        type_name = @type.camel_case_name

        attributes_block = ''
        @dirty_attributes.each do |name|
          attributes_block << "#{name}: \"#{@attributes[name]}\"\n"
        end

        mutation = "
          mutation {
            #{type_name}Update(
              input: {
                id: \"#{self.id}\"
                #{attributes_block}
              }
            ) {
              userErrors {
                field,
                message
              }
            }
          }"

        @dirty_attributes.clear
        request = Request.new(client: @client, type: @type)
        request.from_query(mutation)
      end

      def destroy
        type_name = type.camel_case_name

        mutation = "
          mutation {
            #{type_name}Delete(
              input: {
                id: \"#{self.id}\"
              }
            ) {
              userErrors {
                field,
                message
              }
            }
          }"

        request = Request.new(client: @client, type: @type)
        request.from_query(mutation)
      end

      private

      def all_from_connection(field)
        connection_type = @type.connections[field]
        return_type_name = connection_type.gsub('Connection', '')
        return_type = @client.schema.type(return_type_name)
        ConnectionProxy.new(parent: self, client: @client, type: return_type, field: field)
      end

      def all_from_list(field)
        return_type_name = @type.lists[field]
        return_type = @client.schema.type(return_type_name)
        ListProxy.new(parent: self, client: @client, type: return_type, field: field)
      end
    end
  end
end
