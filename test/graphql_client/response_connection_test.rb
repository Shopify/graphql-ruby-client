require 'test_helper'

module GraphQL
  module Client
    class ResponseConnectionTest < Minitest::Test
      def test_each_yields_the_edges_node
        connection = ResponseConnection.new(
          'edges' => [
            {
              'cursor' => 'first-cursor',
              'node' => {
                'id' => 1,
                'title' => 'Product 1'
              }
            },
            {
              'cursor' => 'last-cursor',
              'node' => {
                'id' => 2,
                'title' => 'Product 2'
              }
            }
          ]
        )

        assert_equal connection.edges.map(&:node), connection.to_a
      end

      def test_delegates_has_next_page_to_page_info
        connection = ResponseConnection.new(
          'pageInfo' => {
            'hasNextPage' => true
          }
        )

        assert_equal true, connection.has_next_page?
      end

      def test_delegates_has_previous_page_to_page_info
        connection = ResponseConnection.new(
          'pageInfo' => {
            'hasPreviousPage' => false
          }
        )

        assert_equal false, connection.has_previous_page?
      end
    end
  end
end
