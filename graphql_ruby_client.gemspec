# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'graphql_client/version'

Gem::Specification.new do |s|
  s.name = 'graphql_client'
  s.version = GraphQL::Client::VERSION
  s.author = "Shopify"

  s.summary = ''
  s.description = ''
  s.email = 'developers@jadedpixel.com'
  s.homepage = 'http://www.shopify.com/partners/apps'

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")

  s.rdoc_options = ["--charset=UTF-8"]
  s.license = 'MIT'

  dev_dependencies = [['mocha', '>= 0.9.8'],
                      ['webmock'],
                      ['minitest', '~> 5.8'],
                      ['pry'],
                      ['simplecov'],
                      ['rake'],
                      ['rubocop'],
                      ['vcr']]

  dev_dependencies.each { |dep| s.add_development_dependency(*dep) }
end
