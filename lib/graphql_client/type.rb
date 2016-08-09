module GraphQL
  module Client
    class Type
      PRIMITIVES = %w(
        Boolean
        DateTime
        ID
        Int
        String
      )

      attr_reader :fields, :lists, :objects, :connections, :name, :field_arguments

      def determine_type(type)
        return type if type.is_a? String

        if type.key?(:ofType)
          return determine_type(type[:ofType]) unless type[:ofType].nil?
        end

        return type[:name]
      end

      def initialize(name, type)
        @name = name
        @type = type
        @fields = {}
        @objects = {}
        @connections = {}
        @lists = {}
        @field_arguments = {}

        if @type[:fields] != nil
          @type[:fields].each do |field|
            if field.key?(:args)
              if field[:args].length > 0
                @field_arguments[field[:name]] = []
                field[:args].each do |argument|
                  @field_arguments[field[:name]] << GraphQL::Client::Argument.new(argument['name'], argument['description'])
                end
                if field.fetch('type', {}).fetch('ofType', nil).nil?
                  # puts "Node detected for #{field[:name]}"
                  next
                else
                  if field.fetch('type', {}).fetch('ofType', {}).fetch('name', '').end_with? 'Connection'
                    @connections[field[:name]] = determine_type(field[:type])
                    next
                  else
                    type = determine_type(field[:type])
                    @lists[field[:name]] = type
                    next
                  end
                end
              end
            end

            unless field[:type][:ofType] == nil
              kind = field[:type][:ofType][:kind]
            end

            if kind == 'LIST'
              @objects[field[:name]] = kind
            else
              # Non-null types are wrapped in two layers
              unless field[:type].fetch(:ofType).nil?
                type_name = field[:type][:ofType][:name]
              else
                type_name = field[:type][:name]
              end

              @fields[field[:name]] = Field.new(field[:name], type_name, false)
            end
          end
        end
      end

      def primitive_fields
        @fields.select{|name,field| PRIMITIVES.include? field.type_name}
      end
    end
  end
end
