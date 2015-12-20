require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.test_files = ['test/test_helper.rb']
end
