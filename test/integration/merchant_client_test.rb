require_relative '../test_helper'
require 'minitest/autorun'

class MerchantClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'

  def setup
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
    schema_string = File.read(schema_path)

    @schema = GraphQL::Client::Schema.new(schema_string)
    @client = GraphQL::Client::Base.new(
      schema: @schema,
      url: URL,
      username: ENV.fetch('MERCHANT_USERNAME'),
      password: ENV.fetch('MERCHANT_PASSWORD')
    )
  end

  def test_find_shop_and_products
    shop = @client.shop
    assert_equal 'Toronto', shop.city

    products = shop.products
    assert_equal 5, products.length
    assert_equal 5, products.map(&:title).uniq.length
  end

  def test_updating_product
    shop = @client.shop
    products = shop.products

    title = "Renamed Product - #{Time.new.to_i}"
    product = products.to_a.last
    product.title = title
    product.save

    product = @client.shop.products.to_a.last
    assert_equal title, product.title
  end
end
