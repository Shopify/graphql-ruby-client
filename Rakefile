require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.warning = false
  t.test_files = FileList.new do |test_files|
    test_files.include('test/*_test.rb')
    test_files.include('test/integration/merchant_schema_test.rb')

    if ENV['MERCHANT_USERNAME'] && ENV['MERCHANT_PASSWORD']
      test_files.include('test/integration/merchant_client_test.rb')
    end

    if ENV['MERCHANT_TOKEN']
      test_files.include('test/integration/merchant_channel_test.rb')
    end

    if ENV['STOREFRONT_TOKEN']
      test_files.include('test/integration/storefront*_test.rb')
    end
  end
end

task default: :test
