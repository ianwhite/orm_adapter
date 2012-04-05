require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
$:.push File.expand_path("../lib", __FILE__)
require "orm_adapter/version"

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = ['lib/**/*.rb', 'README.rdoc']
  end
rescue LoadError
  task :doc do
    puts "install yard to generate the docs"
  end
end

task :build do
  system "gem build orm_adapter.gemspec"
end

namespace :release do
  task :rubygems => :pre do
    system "gem push orm_adapter-#{OrmAdapter::VERSION}.gem"
  end
  
  task :github => :pre do
    require 'git'
    tag = "v#{OrmAdapter::VERSION}"
    git = Git.open('.')
    
    if (git.tag(tag) rescue nil)
      raise "** repo is already tagged with: #{tag}"
    end
    
    git.add_tag(tag)
    git.push('origin', tag)
  end
  
  task :pre => [:spec, :build] do
    require 'git'
    git = Git.open('.')
    
    if File.exists?("Gemfile.lock") && File.read("Gemfile.lock") != File.read("Gemfile.lock.development")
      cp "Gemfile.lock", "Gemfile.lock.development"
      raise "** Gemfile.lock.development has been updated, please commit these changes."
    end
    
    if git.status.changed.any? || git.status.added.any? || git.status.deleted.any?
      raise "** repo is not clean, try committing some files"
    end
    
    if git.object('HEAD').sha != git.object('origin/master').sha
      raise "** origin does not match HEAD, have you pushed?"
    end
  end
  
  task :all => ['release:github', 'release:rubygems']
end
