require_relative '../test_helper'
require 'minitest/autorun'

class FieldTest < Minitest::Test
  def test_field_parsing
    raw_field = { "name" => "product",
                  "description" => nil,
                  "args" =>
      [{ "name" => "id",
         "description" => nil,
         "type" =>
         { "kind" => "NON_NULL",
           "name" => "Non-Null",
           "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
         "defaultValue" => nil }],
                  "type" => { "kind" => "OBJECT", "name" => "Product", "ofType" => nil },
                  "isDeprecated" => false,
                  "deprecationReason" => nil }

    field = GraphQL::Client::Field.new(raw_field)

    assert_equal('product', field.name)
    assert_equal('Product', field.type_name)
    assert_equal('OBJECT', field.type_kind)
    assert_equal(false, field.required)
  end

  def test_connection_parsing
    raw_field = { "name" => "collects",
                  "description" => nil,
                  "args" =>
      [{ "name" => "first",
         "description" => nil,
         "type" =>
         { "kind" => "NON_NULL",
           "name" => "Non-Null",
           "ofType" => { "kind" => "SCALAR", "name" => "Int", "ofType" => nil } },
         "defaultValue" => nil },
       { "name" => "after",
         "description" => nil,
         "type" => { "kind" => "SCALAR", "name" => "String", "ofType" => nil },
         "defaultValue" => nil },
       { "name" => "reverse",
         "description" => nil,
         "type" => { "kind" => "SCALAR", "name" => "Boolean", "ofType" => nil },
         "defaultValue" => "false" }],
                  "type" =>
      { "kind" => "NON_NULL",
        "name" => "Non-Null",
        "ofType" => { "kind" => "OBJECT", "name" => "CollectConnection", "ofType" => nil } },
                  "isDeprecated" => false,
                  "deprecationReason" => nil }

    field = GraphQL::Client::Field.new(raw_field)

    assert_equal('Collect', field.type_name)
    assert(field.connection?)
  end

  def test_fields_with_differently_named_return_types
    raw_field = { "name" => "variants",
                  "description" => nil,
                  "args" =>
      [{ "name" => "first",
         "description" => "Truncate the array result to this size",
         "type" => { "kind" => "SCALAR", "name" => "Int", "ofType" => nil },
         "defaultValue" => nil }],
                  "type" =>
      { "kind" => "NON_NULL",
        "name" => "Non-Null",
        "ofType" =>
        { "kind" => "LIST",
          "name" => "List",
          "ofType" =>
          { "kind" => "NON_NULL",
            "name" => "Non-Null",
            "ofType" => { "kind" => "OBJECT", "name" => "ProductVariant" } } } },
                  "isDeprecated" => false,
                  "deprecationReason" => nil }

    field = GraphQL::Client::Field.new(raw_field)

    assert_equal('ProductVariant', field.type_name)
    assert(field.list?)
  end
end
