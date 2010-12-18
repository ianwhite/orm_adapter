require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'yard'

$:.unshift File.expand_path('lib')
require 'orm_adapter/version'

task :default => :spec

desc "Run the specs"
RSpec::Core::RakeTask.new(:spec)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "orm_adapter"
    gem.version = OrmAdapter::VERSION
    gem.summary = %Q{Provides a single point of entry for using basic features of ruby ORMs}
    gem.description = %Q{Provides a single point of entry for using basic features of ruby ORMs}
    gem.email = "ian.w.white@gmail.com"
    gem.homepage = "http://github.com/ianwhite/orm_adapter"
    gem.authors = ["Ian White", "Jose Valim"]
  end
  Jeweler::GemcutterTasks.new
  
  namespace :release do
    desc "release to github and gemcutter"
    task :all => ['release', 'gemcutter:release']
  end
  
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', 'README.rdoc']
end
