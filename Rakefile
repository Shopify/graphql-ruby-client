require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

task(default: :test)

def load_gem_and_dummy
  $LOAD_PATH.push File.expand_path("../lib", __FILE__)
  $LOAD_PATH.push File.expand_path("../test", __FILE__)
  require "graphql_client"
end
