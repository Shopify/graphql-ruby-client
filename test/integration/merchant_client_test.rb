require 'test_helper'

class MerchantClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'

  def setup
    schema_string = File.read(fixture_path('merchant_schema.json'))

    @schema = GraphQLSchema.new(schema_string)
    @client = GraphQL::Client.new(
      schema: @schema,
      url: URL,
      username: ENV.fetch('MERCHANT_USERNAME'),
      password: ENV.fetch('MERCHANT_PASSWORD')
    )
  end

  def test_find_shop_and_products
    shop = @client.shop(fields: ['city'])
    assert_equal 'Toronto', shop.city

    products = shop.products(fields: ['id', 'title'])
    assert_equal 5, products.length
    assert_equal 5, products.map(&:title).uniq.length

    variants = products.first.variants(fields: ['price'])
    variant = variants.first
    refute_nil variant.price
  end

  def test_product_tags
    product = @client.shop.products(fields: ['tags']).first
    tags = product.tags
    assert_equal ['summer', 'winter'], tags.sort
  end

  def test_updating_product
    shop = @client.shop
    products = shop.products(fields: ['id', 'title'])

    title = "Renamed Product - #{Time.new.to_i}"
    product = products.to_a.last
    product.title = title
    product.save

    product = @client.shop.products(fields: ['title']).to_a.last
    assert_equal title, product.title
  end
end
