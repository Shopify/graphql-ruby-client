require_relative '../test_helper'
require 'minitest/autorun'

class StorefrontClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/api/graph'
  USERNAME = ENV.fetch('STOREFRONT_TOKEN')

  def setup
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/storefront_schema.json')
    schema_string = File.read(schema_path)

    @schema = GraphQLSchema.new(schema_string)
    @client = GraphQL::Client.new(
      schema: @schema,
      url: URL,
      username: USERNAME
    )
  end

  def test_request_counts
    spy = Spy.on_instance_method(GraphQL::Client::Request, :send_request).and_call_through
    shop = @client.shop
    assert_equal(0, spy.calls.count)

    shop.name
    assert_equal(1, spy.calls.count)

    products = shop.products
    assert_equal(1, spy.calls.count)

    product = products.first
    assert_equal(2, spy.calls.count)

    product.title
    assert_equal(2, spy.calls.count)
  end

  def test_find_shop_and_products
    shop = @client.shop
    assert_equal('Toronto', shop.city)

    products = shop.products
    assert_equal 5, products.length

    id = products.to_a.find { |p| p.title == 'Abridgable Concrete Coat' }.id
    found_product = @client.product(id: id)
    assert_equal(id, found_product.id)

    variants = found_product.variants
    assert_equal(2, variants.length)

    variant = variants.first
    assert_equal('12.00', variant.price)
  end

  def test_paginated_request
    product = @client.shop.products.to_a.last

    collections = product.collections
    assert_equal 1, collections.length
  end

  def test_batch_paginated_request
    client = GraphQL::Client.new(
      schema: @schema,
      url: URL,
      username: USERNAME,
      per_page: 3
    )

    shop = client.shop
    assert_equal('Toronto', shop.city)

    products = shop.products
    assert_equal 5, products.length
    assert_equal 5, products.map(&:title).uniq.length
  end
end
