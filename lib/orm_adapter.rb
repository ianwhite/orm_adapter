require 'orm_adapter/register'
require 'orm_adapter/contract'

module OrmAdapter
end

require 'orm_adapter/adapters/active_record' if defined?(ActiveRecord::Base)
require 'orm_adapter/adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'orm_adapter/adapters/mongoid'       if defined?(Mongoid::Document)