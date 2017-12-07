# A Ruby GraphQL Client

[![Build Status](https://travis-ci.org/Shopify/graphql-ruby-client.svg?branch=master)](https://travis-ci.org/Shopify/graphql-ruby-client)

This is an early stage attempt at a *generic* GraphQL client in Ruby.

This client offers two APIs:

1. Query Builder
2. Raw Queries

The Query Builder is considered unstable and should be used with caution.

We recommend start with raw queries since it offers an easy migration path to another API or library. With the raw queries, you are just writing plain GraphQL queries as strings.

Below you'll find some usage examples.

## Usage

Create a client:

```ruby
client = GraphQL::Client.new(Pathname.new('path/to/schema.json')) do
  configure do |c|
    c.url = "https://#{shopify_domain}/admin/api/graphql.json"
    c.read_timeout = 1 # 5 seconds is the default
    c.headers = {
      'X-Shopify-Access-Token' => shopify_token
    }
  end
end
```

### Raw Queries

```ruby
client.raw_query('
  query {
    shop {
       name
      }
    }
')
```

### Query Builder

```ruby
query = client.build_query do |q|
  q.add_field('shop') do |shop|
    shop.add_field('name')
  end
end

client.query(query)
```

More complex query using a connection:

```ruby
query = client.build_query do |q|
  q.add_field('product', id: 'gid://Product/1') do |product|
    product.add_connection('images', first: 10) do |connection|
      connection.add_field('src')
    end
  end

  q.add_field('shop') do |shop|
    shop.add_field('name')

    shop.add_field('billingAddress') do |billing_address|
      billing_address.add_fields('city', 'country')
    end
  end
end

client.query(query)
```

## Responses

Both `query` and `raw_query` methods return a response object that converts the JSON to Ruby objects offering easy method access instead of via a Hash.

Example:

```ruby
response = client.raw_query('
  query {
    shop {
       name
      }
    }
')

puts response.shop.name
```
