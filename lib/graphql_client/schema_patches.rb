# frozen_string_literal: true

class GraphQLSchema
  def query_root
    type(query_root_name)
  end

  def type(name)
    types_by_name.fetch(name)
  end

  class TypeDefinition
    def field(name)
      fields_by_name.fetch(name)
    end
  end
end
