require_relative 'lib/graphql_client/version'

Gem::Specification.new do |s|
  s.author = 'Shopify'
  s.description = ''
  s.email = 'developers@jadedpixel.com'
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://www.shopify.com/partners/apps'
  s.license = 'MIT'
  s.name = 'graphql_client'
  s.required_ruby_version = '>= 2.3'
  s.summary = ''
  s.test_files = `git ls-files -- {test}/*`.split("\n")
  s.version = GraphQL::Client::VERSION
  s.executables = 'graphql-client'

  s.add_runtime_dependency 'graphql_schema', '~> 0.1.5'

  s.add_development_dependency 'graphql', '~> 1.6.4'
  s.add_development_dependency 'minitest', '~> 5.8'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock', '~> 3.1.1'
end
