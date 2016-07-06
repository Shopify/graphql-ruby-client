# frozen_string_literal: true

module GraphQL
  module Client
    class ResponseConnection < ResponseObject
      extend Forwardable
      include Enumerable

      def_delegator :page_info, :has_next_page, :has_next_page?
      def_delegator :page_info, :has_previous_page, :has_previous_page?

      def each
        return enum_for(:each) unless block_given?
        edges.each { |edge| yield edge.node }
      end
    end
  end
end
