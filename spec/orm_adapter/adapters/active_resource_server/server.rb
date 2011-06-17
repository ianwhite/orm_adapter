require 'rubygems'
ENV['RAILS_ENV'] = 'test'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)

class Rails::Application::Configuration
 def database_configuration
   {'test' => {'adapter' => 'sqlite3', 'database' => '/tmp/orm_adapter_test.sqlite'}}
 end
end

ActiveSupport.on_load(:before_initialize) do
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:users, :force => true) {|t| t.string :name; t.integer :rating; }
      create_table(:notes, :force => true) {|t| t.belongs_to :owner, :polymorphic => true }
    end
  end
end

module ActiveResourceServer
  class Application < Rails::Application
    config.active_support.deprecation = :log
    config.secret_token = ActiveSupport::SecureRandom.hex(30)
    config.logger = Logger.new ::Rails.root.to_s + "/server.log"

    initializer 'routes' do |app|
      app.routes.draw do
        resources :users
        resources :notes
      end
    end
  end
end

require File.expand_path('../models', __FILE__)
require File.expand_path('../controllers', __FILE__)

ActiveResourceServer::Application.initialize!
