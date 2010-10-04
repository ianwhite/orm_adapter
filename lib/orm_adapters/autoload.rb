# auto require for active record, datamapper and mongoid orms
require 'orm_adapters/active_record' if defined?(ActiveRecord::Base)
require 'orm_adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'orm_adapters/mongoid'       if defined?(Mongoid::Document)