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

  def test_includes_with_images
    image_count = 0
    products = @client.shop.products(
      fields: ['title'],
      includes: { variants: ['title', images: ['src']] }
    )

    products.each do |product|
      variants = product.variants
      assert variants.length.nonzero?

      variants.each do |variant|
        refute_nil variant.title

        variant.images.each do |image|
          image_count += 1
          refute_nil image.src
        end
      end
    end

    assert image_count.nonzero?
  end

  def test_product_images
    product = @client.shop.products(fields: ['title']).find { |p| p.title == 'Abridgable Concrete Coat' }
    images = product.images(fields: ['src'])

    assert images.length.positive?
    images.each do |image|
      refute_nil image.src
    end
  end

  def test_shop_and_products
    shop = @client.shop
    address = shop.billing_address(fields: ['city'])
    assert_equal('Toronto', address.city)

    products = shop.products(fields: ['title'])
    assert_equal 5, products.length

    id = products.to_a.find { |p| p.title == 'Abridgable Concrete Coat' }.id
    found_product = @client.product(id: id, fields: ['title'])
    assert_equal(id, found_product.id)

    variants = found_product.variants(fields: ['price'])
    assert_equal(2, variants.length)

    variant = variants.first
    assert_equal('12.00', variant.price)
  end

  def test_product_tags
    product = @client.shop.products(fields: ['title', 'tags']).find { |p| p.title == 'Abridgable Concrete Coat' }
    refute(product.tags.empty?)
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

    shop = client.shop
    address = shop.billing_address(fields: ['city'])
    assert_equal('Toronto', address.city)

    products = shop.products(fields: ['title'])
    assert_equal 5, products.length
    assert_equal 5, products.map(&:title).uniq.length
  end
end
