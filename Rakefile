require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << 'test' << 'lib'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.warning = false
end
