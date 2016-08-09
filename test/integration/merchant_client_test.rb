require_relative '../test_helper'
require 'minitest/autorun'

class MerchantClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'
  SECRET = 'b1d6a587d0b3fe77e5b07b818a69081f'

  def setup
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
    schema_string = File.read(schema_path)

    @schema = GraphQL::Client::Schema.new(schema_string)
    @client = GraphQL::Client::Base.new(
      schema: @schema,
      url: URL,
      username: 'e3c3e27694e5702e985bdcd8db266c64',
      password: '223fcadc3bb7255266ab86d5693fa640'
    )
  end

  def test_find_shop_and_products
    shop = @client.find('Shop')
    assert_equal 'Toronto', shop['city']

    products = shop.all('products')
    assert_equal 5, products.length
  end
end