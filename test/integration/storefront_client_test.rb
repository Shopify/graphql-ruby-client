require 'test_helper'

class StorefrontClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/api/graph'
  USERNAME = ENV.fetch('STOREFRONT_TOKEN')

  def setup
    WebMock.allow_net_connect!

    schema_string = File.read(fixture_path('storefront_schema.json'))
    @schema = GraphQLSchema.new(schema_string)

    @client = GraphQL::Client.new(@schema) do
      configure do |c|
        c.url = URL
        c.username = USERNAME
      end
    end
  end

  def test_request_counts
    spy = Spy.on_instance_method(GraphQL::Client::Request, :send_request).and_call_through
    shop = @client.shop(fields: ['name'])
    assert_equal(0, spy.calls.count)

    shop.name
    assert_equal(1, spy.calls.count)

    products = shop.products(fields: ['title'])
    assert_equal(1, spy.calls.count)

    product = products.first
    assert_equal(2, spy.calls.count)

    product.title
    assert_equal(2, spy.calls.count)
  end

  def test_find_shop_and_products
    shop = @client.shop(fields: ['city'])
    assert_equal('Toronto', shop.city)

    products = shop.products(fields: ['id', 'title'])
    assert_equal 5, products.length

    id = products.to_a.find { |p| p.title == 'Abridgable Concrete Coat' }.id
    found_product = @client.product(id: id, fields: ['id', 'title'])
    assert_equal(id, found_product.id)

    variants = found_product.variants(fields: ['price'])
    assert_equal(2, variants.length)

    variant = variants.first
    assert_equal('12.00', variant.price)
  end

  def test_paginated_request
    product = @client.shop.products(fields: ['title', 'id']).to_a.last

    collections = product.collections(fields: ['title'])
    assert_equal 1, collections.length
  end

  def test_batch_paginated_request
    client = GraphQL::Client.new(@schema) do
      configure do |c|
        c.url = URL
        c.username = USERNAME
        c.per_page = 3
      end
    end

    shop = client.shop(fields: ['city'])
    assert_equal('Toronto', shop.city)

    products = shop.products(fields: ['title'])
    assert_equal 5, products.length
    assert_equal 5, products.map(&:title).uniq.length
  end
end
