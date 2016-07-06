require_relative '../test_helper'
require 'minitest/autorun'

class StorefrontSchemaTest < Minitest::Test
  def test_loading_storefront_schema
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/storefront_schema.json')
    schema_string = File.read(schema_path)

    schema = GraphQL::Client::Schema.new(schema_string)
    assert !schema.types.empty?

    product_type = schema.types["Product"]

    expected_fields = %w(createdAt
                         handle
                         id
                         productType
                         publishedAt
                         tags
                         title
                         updatedAt
                         vendor)
    assert_equal(expected_fields, product_type.fields.keys.sort)

    expected_connections = %w(collections)
    assert_equal(expected_connections, product_type.connections.keys.sort)

    expected_lists = %w(images
                        options
                        variants)
    assert_equal(expected_lists, product_type.lists.keys.sort)

    # validate that the type matches for sub-queries
    assert_equal('ProductVariant', product_type.lists['variants'])
  end
end
