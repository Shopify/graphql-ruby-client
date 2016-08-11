require_relative '../test_helper'
require 'minitest/autorun'

class SchemaTest < Minitest::Test
  def schema
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
    schema_string = File.read(schema_path)
    GraphQL::Client::Schema.new(schema_string)
  end

  def test_array_access_returns_the_type_by_name
    assert_equal 'Product', schema['Product'].name
  end

  def test_query_root_looks_up_query_root_type
    assert_equal 'QueryRoot', schema['QueryRoot'].name
  end

  def test_type_looks_up_type_by_name_downcased
    shop_type = schema['Shop']
    assert_equal shop_type.name, schema.type('shop').name
  end

  def test_types_returns_all_types_from_schema
    assert_equal 189, schema.types.size
    assert_equal GraphQL::Client::Type, schema.types.values.first.class
  end
end
