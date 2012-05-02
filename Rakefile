#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

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

Bundler::GemHelper.install_tasks

task :release => :check_gemfile

task :check_gemfile do
  if File.exists?("Gemfile.lock") && File.read("Gemfile.lock") != File.read("Gemfile.lock.development")
    cp "Gemfile.lock", "Gemfile.lock.development"
    raise "** Gemfile.lock.development has been updated, please commit these changes."
  end
end