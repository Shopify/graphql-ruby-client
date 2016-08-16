require_relative '../test_helper'
require 'minitest/autorun'

class StorefrontSchemaTest < Minitest::Test
  def test_loading_storefront_schema
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/storefront_schema.json')
    schema_string = File.read(schema_path)
    schema = GraphQL::Client::Schema.new(schema_string)

    query_root = schema.query_root
    assert_equal('Node', query_root.interfaces['node'].type_name)

    product_type = schema.type('Product')

    expected_scalars = %w(createdAt
                          handle
                          id
                          productType
                          publishedAt
                          title
                          updatedAt
                          vendor)
    assert_equal(expected_scalars, product_type.scalars.keys.sort)

    expected_connections = %w(collections)
    assert_equal(expected_connections, product_type.connections.keys.sort)

    expected_lists = %w(images
                        options
                        variants)
    assert_equal(expected_lists, product_type.lists.keys.sort)

    # validate that the type matches for sub-queries
    assert(product_type.lists['variants'].list?)
  end
end
