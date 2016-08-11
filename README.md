# A Ruby GraphQL Client

This is a fairly simple GraphQL client gem for Ruby. It implements most of the
basic features you'd expect such as:

- Schema and type information parsing
- Pagination
- Mutations

## Usage

The API is similiar to ActiveRecord/ActiveResource. First initialize a schema -
it's recommended that you load this schema once upon application boot from a
stored file:

```ruby
schema_path = File.join(File.dirname(__FILE__), 'your_schema.json')
schema_string = File.read(schema_path)
schema = GraphQL::Client::Schema.new(schema_string)
```

Now initialize a `Client` object. This is the main interface to the remote
GraphQL server, and contains all the network layer information such as
authentication data.

```ruby
client = GraphQL::Client::Base.new(
  schema: schema,
  url: URL,
  username: USERNAME,
  password: PASSWORD,
  headers: {
    'X-Authentication-Token': TOKEN
  }
)
```

You can use any combination of username, password and arbitrary headers.
Additionally the content type can be specified here (which defaults to
`application/json`).

The Client is considered the QueryRoot in GraphQL terminology; any fields on
the query root can be directly requested, and attributes are exposed as methods
on the objects:

```ruby
shop = @client.shop
products = shop.products
products.first.title == 'A Cool Product'
```

The schema is used to determine what types are returned when fields are
requested (such as primitive objects, lists, connections, and so forth).

Finally, mutations are (naively) supported as well:

```ruby
product = client.find("gid://shopify/Products/1")
product.title = title
product.save
```

Additionally in the above example the `find` method is used to fetch a single
object based on the identifier. You can create new objects off of the
collection:

```ruby
products.create(title: "Another Cool Product")
```

The creation returns the newly fetched object from the server. Deletion is
supported as well of course:

```ruby
public_access_tokens = client.shop.public_access_tokens
new_token = public_access_tokens.create(title: 'Test')
new_token.destroy
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
- Allowing users to pass raw GraphQL queries into the library (for regular
  queries and mutations)

## Release Plans

This can be open sourced and probably should be; there's no Ruby client for
GraphQL yet and this would fill a community niche. There's nothing Shopify
specific in the codebase other than the integration tests (which can be rebased
out of existence and moved to a private repo).
