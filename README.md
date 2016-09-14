# A Ruby GraphQL Client

**Note: do not use this yet. It's experimental and changes frequently**

This is an early stage attempt at a *generic* GraphQL client in Ruby.

Below you'll find some usage examples.

## Usage

Create a client:

```ruby
schema_string = File.read('path/to/schema.json')
schema = GraphQLSchema.new(schema_string)

client = GraphQL::Client.new do
  configure do |c|
    c.url = 'http://example.com'
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

### ActiveRecord Style API

This API is the most experimental/unfinished one.

It currently only supports building a tree of fields with explicit field selections.

```ruby
shop = client.shop(fields: ['city'])
products = shop.products(fields: ['id', 'title'])
titles = products.map(&:title)
```

## Testing

Right now the tests are fairly tricky to get correct. Most of the functionality
is covered by integration tests which can use a production or local Shopify
store and operates in the following contexts:

- Merchant
- Channel (via the Merchant API)
- Customer (via the StoreFront API)

The following environment variables are used to drive the integration tests:

- `MERCHANT_USERNAME`
- `MERCHANT_PASSWORD`
- `MERCHANT_TOKEN`
- `STOREFRONT_TOKEN`

Unit tests will run regardless of which variables are present.

## TODO

There's a lot missing right now. Some of the more immediate things to fix are:

- Query validation
- Mutation matching and validation
- GraphQL-level response validation and error checks
