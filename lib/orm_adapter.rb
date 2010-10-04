require 'orm_adapter/contract'
require 'orm_adapter/instance'
require 'orm_adapter/to_adapter'
require 'orm_adapter/register'

module OrmAdapter
  def self.for(klass)
    Instance.new(klass)
  end
end

require 'orm_adapter/adapters/active_record' if defined?(ActiveRecord::Base)
require 'orm_adapter/adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'orm_adapter/adapters/mongoid'       if defined?(Mongoid::Document)