require 'test_helper'

module GraphQL
  module Client
    class ResponseObjectTest < Minitest::Test
      def test_builds_response_objects_from_hashes
        result = ResponseObject.new(
          'myshop' => {
            'name' => 'My Shop',
          }
        )

        assert_equal({ 'name' => 'My Shop' }, result.myshop.data)
      end

      def test_builds_response_objects_from_arrays
        result = ResponseObject.new(
          'shop' => {
            'fulfillmentServices' => [
              { 'serviceName' => 'service 1' },
              { 'serviceName' => 'service 2' },
            ]
          }
        )

        assert_equal 2, result.shop.fulfillment_services.size

        service1, service2 = result.shop.fulfillment_services

        assert_equal({ 'serviceName' => 'service 1' }, service1.data)
        assert_equal({ 'serviceName' => 'service 2' }, service2.data)
      end

      def test_builds_response_objects_from_arrays_of_strings
        result = ResponseObject.new(
          "productPublish" => {
            "userErrors" => [
              {
                "field" => ["id"],
                "message" => "Product does not exist"
              }
            ]
          }
        )

        assert_equal 1, result.productPublish.user_errors.size
        assert_equal 1, result.productPublish.user_errors.first.field.size

        assert_equal(['id'], result.productPublish.user_errors.first.field)
        assert_equal('Product does not exist', result.productPublish.user_errors.first.message)
      end

      def test_builds_response_connections_based_on_edges_existence
        result = ResponseObject.new(
          'products' => {
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
          }
        )

        assert_instance_of ResponseConnection, result.products
      end

      def test_defines_methods_from_data
        result = ResponseObject.new(
          'myshop' => {
            'name' => 'My Shop',
            'setupRequired' => false,
          }
        )

        myshop = result.myshop

        assert_equal 'My Shop', myshop.name
        assert_equal false, myshop.setup_required
        assert_equal false, myshop.setupRequired
      end

      def test_defines_instance_variable_during_method_access
        result = ResponseObject.new(
          'shop' => {
            'name' => 'My Shop',
          }
        )

        refute result.instance_variable_defined?("@shop")

        result.shop

        assert result.instance_variable_defined?("@shop")
        assert_equal result.shop, result.instance_variable_get("@shop")
      end
    end
  end
end
