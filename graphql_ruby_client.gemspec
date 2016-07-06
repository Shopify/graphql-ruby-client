# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'graphql_client/version'

Gem::Specification.new do |s|
  s.name = %q{graphql_client}
  s.version = GraphQL::Client::VERSION
  s.author = "Shopify"

  s.summary = %q{}
  s.description = %q{}
  s.email = %q{developers@jadedpixel.com}
  s.homepage = %q{http://www.shopify.com/partners/apps}

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = ["--charset=UTF-8"]
  s.license = 'MIT'

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'globalid'

  dev_dependencies = [['mocha', '>= 0.9.8'],
                      ['webmock'],
                      ['minitest', '~> 5.8'],
                      ['pry'],
                      ['simplecov'],
                      ['rake'],
                      ['rubocop'],
                      ['vcr']
  ]

  dev_dependencies.each { |dep| s.add_development_dependency(*dep) }
end
