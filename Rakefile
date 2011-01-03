require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'yard'
$:.push File.expand_path("../lib", __FILE__)
require "orm_adapter/version"

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', 'README.rdoc']
end

task :build do
  system "gem build orm_adapter.gemspec"
end

namespace :release do
  task :rubygems => :build do
    system "gem push orm_adapter-#{OrmAdapter::VERSION}"
  end
  
  task :github => :build do
    `git rev-parse HEAD` == `git rev-parse origin/master` or raise "\n** origin does not match HEAD, have you pushed?"
    tag = "v#{OrmAdapter::VERSION}"
    `git tag`.split("\n").include?(tag) and raise "\n** tag: #{tag} is already tagged."
    `git tag #{tag}`
    `git push --tags`
  end
  
  task :all => ['release:github', 'release:rubygems']
end