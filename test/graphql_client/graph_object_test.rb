require 'test_helper'

module GraphQL
  module Client
    class GraphObjectTest < Minitest::Test
      def setup
        @schema = GraphQLSchema.new(schema_fixture('schema.json'))
      end

      def test_builds_graph_objects_from_hashes
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop', as: 'myshop')
        shop.add_field('name')

        data = {
          'myshop' => {
            'name' => 'My Shop',
          }
        }

        result = GraphObject.new(data: data, query: query)
        myshop = result.myshop

        assert_equal data.fetch('myshop'), myshop.data
        assert_equal shop, myshop.query
        assert_equal result, myshop.parent
      end

      def test_builds_graph_objects_from_arrays
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop')
        product = shop.add_field('productByHandle', handle: 'handle')
        product.add_field('tags')

        data = {
          'shop' => {
            'productByHandle' => {
              'tags' => [
                'tag1',
                'tag2',
              ]
            }
          }
        }

        result = GraphObject.new(data: data, query: query)

        assert_equal ['tag1', 'tag2'], result.shop.product_by_handle.tags
      end

      def test_instantiates_a_graph_connection_for_connection_fields
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop')

        data = {
          'shop' => {}
        }

        shop.stub(:connection?, true) do
          result = GraphObject.new(data: data, query: query)
          assert_instance_of GraphConnection, result.shop
        end
      end

      def test_instantiates_a_graph_node_for_node_types
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop')

        data = {
          'shop' => {}
        }

        shop.stub(:node?, true) do
          result = GraphObject.new(data: data, query: query)
          assert_instance_of GraphNode, result.shop
        end
      end

      def test_defines_methods_from_data
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop', as: 'myshop')
        shop.add_fields('name', 'termsOfService')

        data = {
          'myshop' => {
            'name' => 'My Shop',
            'termsOfService' => false,
          }
        }

        result = GraphObject.new(data: data, query: query)
        myshop = result.myshop

        assert_equal 'My Shop', myshop.name
        assert_equal false, myshop.terms_of_service
        assert_equal false, myshop.termsOfService
      end

      def test_defines_instance_variable_during_method_access
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop')
        shop.add_field('name')

        data = {
          'shop' => {
            'name' => 'My Shop',
          }
        }

        result = GraphObject.new(data: data, query: query)
        refute result.instance_variable_defined?("@shop")

        result.shop
        assert result.instance_variable_defined?("@shop")
        assert_equal result.shop, result.instance_variable_get("@shop")
      end

      def test_build_minimal_query_creates_a_new_query_operation_for_the_root_object
        query = Query::QueryDocument.new(@schema) do |root|
          root.add_field('shop') do |non_node|
            non_node.add_field('name')
          end
        end

        data = {
          'shop' => {
            'name' => 'Foo'
          }
        }

        graph = GraphObject.new(data: data, query: query)
        root = nil

        graph.build_minimal_query do |context|
          root = context
        end

        assert_instance_of Query::QueryOperation, root
      end
    end
  end
end
