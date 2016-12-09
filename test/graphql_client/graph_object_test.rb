require 'test_helper'

module GraphQL
  module Client
    class GraphObjectTest < Minitest::Test
      def setup
        @schema = GraphQLSchema.load_schema(fixture_path('merchant_schema.json'))
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
        fulfillment_services = shop.add_field('fulfillmentServices')
        fulfillment_services.add_field('serviceName')

        data = {
          'shop' => {
            'fulfillmentServices' => [
              { 'serviceName' => 'service 1' },
              { 'serviceName' => 'service 2' },
            ]
          }
        }

        result = GraphObject.new(data: data, query: query)
        assert_equal 2, result.shop.fulfillment_services.size

        service1, service2 = result.shop.fulfillment_services

        assert_equal result.shop, service1.parent
        assert_equal result.shop, service2.parent
        assert_equal fulfillment_services, service1.query
        assert_equal fulfillment_services, service2.query
        assert_equal({ 'serviceName' => 'service 1' }, service1.data)
        assert_equal({ 'serviceName' => 'service 2' }, service2.data)
      end

      def test_instantiates_a_graph_connection_for_connection_fields
        query = Query::QueryDocument.new(@schema)
        shop = query.add_field('shop')

        data = {
          'shop' => {}
        }

        shop.field_defn.stub(:connection?, true) do
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
        shop.add_fields('name', 'setupRequired')

        data = {
          'myshop' => {
            'name' => 'My Shop',
            'setupRequired' => false,
          }
        }

        result = GraphObject.new(data: data, query: query)
        myshop = result.myshop

        assert_equal 'My Shop', myshop.name
        assert_equal false, myshop.setup_required
        assert_equal false, myshop.setupRequired
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
        @schema = GraphQLSchema.load_schema(fixture_path('schema.json'))

        query = Query::QueryDocument.new(@schema) do |root|
          root.add_field('nonNode', name: 'Bar') do |non_node|
            non_node.add_field('name')
          end
        end

        data = {
          'nonNode' => {
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

      def test_build_minimal_query_recursively_builds_a_query_by_adding_fields
        @schema = GraphQLSchema.load_schema(fixture_path('schema.json'))

        query = Query::QueryDocument.new(@schema) do |root|
          root.add_field('nonNode', name: 'Bar') do |non_node|
            non_node.add_field('name')
          end
        end

        data = {
          'nonNode' => {
            'name' => 'Foo'
          }
        }

        graph = GraphObject.new(data: data, query: query)
        non_node = nil

        graph.non_node.build_minimal_query do |context|
          non_node = context
        end

        arg = Query::Argument.new('Bar')

        assert_equal 'nonNode', non_node.name
        assert_equal({ name: arg }, non_node.arguments)
      end
    end
  end
end
