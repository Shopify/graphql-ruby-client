# A Ruby GraphQL Client

This is a fairly simple GraphQL client gem for Ruby. It implements most of the
basic features you'd expect such as:

- Schema and type information parsing
- Pagination
- Mutations

There's a lot missing right now. Some of the more immediate things to fix are:

- Making the API use a method syntax similiar to ActiveRecord as opposed to hashes
- Query validation
- Mutation matching and validation
- Error checking
- Allowing users to pass raw GraphQL queries into the library (for regular
  queries and mutations)
  
## Usage

The integration tests are the best place to look at until this stabilizes.

## Tests

Right now the tests are fairly tricky to get correct. Since this is internal to Shopify at this point there is a hardcoded set of access tokens in the integration tests that run through a number of operations in the context of a:

- Merchant
- Channel (via the Merchant API)
- Customer (via the StoreFront API)
