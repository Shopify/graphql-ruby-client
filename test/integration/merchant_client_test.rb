require 'test_helper'

class MerchantClientTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'

  def setup
    WebMock.allow_net_connect!

    schema_string = File.read(fixture_path('merchant_schema.json'))
    @schema = GraphQLSchema.new(schema_string)

    @client = GraphQL::Client.new(@schema) do
      configure do |c|
        c.url = URL
        c.username = ENV.fetch('MERCHANT_USERNAME')
        c.password = ENV.fetch('MERCHANT_PASSWORD')
      end
    end
  end

  def test_find_shop_and_products
    shop = @client.shop
    billing_address = shop.billing_address(:city)
    assert_equal 'Toronto', billing_address.city

    products = shop.products(:title)
    assert_equal 5, products.length
    assert_equal 5, products.map(&:title).uniq.length

    variants = products.first.variants(:price)
    variant = variants.first
    refute_nil variant.price
  end

  def test_product_tags
    product = @client.shop.products(:tags).first
    tags = product.tags
    assert_equal ['summer', 'winter'], tags.sort
  end

  def test_updating_product
    shop = @client.shop
    products = shop.products(:title)

    title = "Renamed Product - #{Time.new.to_i}"
    product = products.to_a.last
    product.title = title
    product.save

    product = @client.shop.products(:title).to_a.last
    assert_equal title, product.title
  end
end
