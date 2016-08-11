require_relative '../test_helper'
require 'minitest/autorun'

class StorefrontClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/api/graph'
  USERNAME = ENV.fetch('STOREFRONT_TOKEN')

  def setup
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/storefront_schema.json')
    schema_string = File.read(schema_path)

    @schema = GraphQL::Client::Schema.new(schema_string)
    @client = GraphQL::Client::Base.new(
      schema: @schema,
      url: URL,
      username: USERNAME
    )
  end

  def test_find_shop_and_products
    shop = @client.shop
    assert_equal('Toronto', shop.city)

    products = shop.products
    assert_equal(5, products.length)
  end

  def test_non_paginated_request
    product = @client.find('gid://shopify/Product/7341512007')
    assert_equal('Abridgable Concrete Coat', product.title)

    variants = product.variants
    assert_equal(2, variants.length)
  end

  def test_paginated_request
    product = @client.find('gid://shopify/Product/7341512007')

    collections = product.collections
    assert_equal(1, collections.length)
  end

  def test_batch_paginated_request
    client = GraphQL::Client::Base.new(
      schema: @schema,
      url: URL,
      username: USERNAME,
      per_page: 3
    )

    shop = client.shop
    assert_equal('Toronto', shop.city)

    products = shop.products
    assert_equal(5, products.length)
    assert_equal(5, products.map(&:title).uniq.length)
  end
end
