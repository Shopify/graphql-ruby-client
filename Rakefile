require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.warning = false
  t.libs << 'test'

  t.test_files = FileList.new do |test_files|
    test_files.include('test/**/*_test.rb')
  end
end

task default: :test
