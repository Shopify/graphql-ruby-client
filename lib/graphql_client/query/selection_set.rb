# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class SelectionSet
        attr_reader :fields, :fragments, :fields, :inline_fragments, :selections

        def initialize
          @fragments = {}
          @fields = {}
          @inline_fragments = []
          @selections = []
        end

        def add_field(query_field)
          @selections << query_field
          @fields[query_field.name] = query_field
        end

        def add_fragment(fragment)
          @selections << fragment
          @fragments[fragment.name] = fragment
        end

        def add_inline_fragment(inline_fragment)
          @selections << inline_fragment
          @inline_fragments << inline_fragment
        end

        def contains?(field_name)
          fields.key?(field_name)
        end

        def empty?
          selections.empty?
        end

        def lookup(name)
          fields.fetch(name)
        end

        def to_query(indent = '')
          selections.map do |field|
            field.to_query(indent: indent + '  ')
          end.join("\n")
        end

        alias_method :to_s, :to_query
      end
    end
  end
end
