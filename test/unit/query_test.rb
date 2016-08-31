require_relative '../test_helper'
require 'minitest/autorun'

module GraphQL
  module Client
    class QueryTest < Minitest::Test
      URL = 'https://big-and-tall-for-pets.myshopify.com/api/graph'
      USERNAME = ENV.fetch('STOREFRONT_TOKEN')

      def setup
        schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
        schema_string = File.read(schema_path)

        @schema = GraphQLSchema.new(schema_string)
        @client = GraphQL::Client::Base.new(
          schema: @schema,
          url: URL,
          username: USERNAME,
          debug: true
        )
      end

      def test_simple_query
        query = @client.build_query
        shop_query = query.add_field('shop')
        shop_query.add_field('name')
        shop_query.add_field('billingAddress').add_fields('city', 'country')

        assert query.to_s.include? 'shop'
      end

      def test_field_with_id
        id = 'gid://shopify/Product/7341512007'
        query = @client.build_query
        query.add_field('product', id: id).add_field('title')

        assert query.to_s.include? 'product'
        assert query.to_s.include? id
      end

      def test_connection
        query = @client.build_query

        shop_query = query.add_field('shop')
        shop_query.add_connection('products', first: 10).add_fields('title')

        assert query.to_s.include? 'node'
        assert query.to_s.include? 'edges'
      end
    end
  end
end
