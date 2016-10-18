require 'test_helper'

class MerchantChannelTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'

  def setup
    WebMock.allow_net_connect!

    schema_string = File.read(fixture_path('merchant_schema.json'))
    @schema = GraphQLSchema.new(schema_string)

    @client = GraphQL::Client.new(@schema) do
      configure do |c|
        c.url = URL
        c.headers = { 'X-Shopify-Access-Token' => ENV.fetch('MERCHANT_TOKEN') }
      end
    end
  end

  def test_product_images
    product = @client.shop.products(:title).find { |p| p.title == 'Abridgable Concrete Coat' }
    images = product.images(:src)

    assert images.length.positive?
    images.each do |image|
      refute_nil image.src
    end
  end

  def test_public_access_tokens
    public_access_tokens = @client.shop.public_access_tokens(:title)
    assert public_access_tokens.count.positive?

    new_token = public_access_tokens.create(title: 'Test')
    assert_equal 32, new_token.access_token.length
    assert_equal 'Test', new_token.title

    new_token.destroy
  end

  def test_manual_pagination
    client = GraphQL::Client.new(@schema) do
      configure do |c|
        c.url = URL
        c.headers = { 'X-Shopify-Access-Token' => ENV.fetch('MERCHANT_TOKEN') }
        c.fetch_all_pages = false
      end
    end

    first_product_batch = client.shop.products(:title, first: 1)
    assert_equal(1, first_product_batch.length)
    assert_equal(true, first_product_batch.next_page?)

    refute_nil(first_product_batch.cursor)
    second_product_batch = client.shop.products(:title, after: first_product_batch.cursor, first: 1)

    refute_equal(first_product_batch.first.title, second_product_batch.first.title)
  end

  def test_channel_by_handle
    channel = @client
      .shop
      .channel_by_handle(:name, handle: 'buy-button-dev')

    assert_equal('Buy Button (Development)', channel.name)

    publications = @client
      .shop
      .channel_by_handle(:name, handle: 'buy-button-dev')
      .product_publications(includes: { product: ['title'] })

    assert_equal(5, publications.length)

    product = publications.first.product
    refute_nil product.title
  end

  def test_publications_products_images
    publications = @client
      .shop
      .channel_by_handle(:name, handle: 'buy-button-dev')
      .product_publications(includes: { 'product' => ['title', 'images' => ['src']] })

    assert_equal(5, publications.length)

    image_count = 0
    publications.each do |publication|
      image_count += publication.product.images.length
    end

    refute_equal(0, image_count)
  end
end
