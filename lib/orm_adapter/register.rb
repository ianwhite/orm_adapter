module OrmAdapter
  module Register
    # Include this module into your ORM adapter
    # this will register the adapter with pickle and it will be picked up for you
    # To create an adapter you should create an inner constant "OrmAdapter"
    #
    # e.g. ActiveRecord::Base::OrmAdapter
    #
    # @see orm_adapters/active_record
    # @see orm_adapters/datamapper
    # @see orm_adapters/mongoid
    def self.included(adapter)
      adapter.extend Contract
      adapters << adapter
    end

    # A collection of registered adapters
    def self.adapters
      @@adapters ||= []
    end
    
    # all model classes from all registered adapters
    def self.model_classes
      adapters.map{|a| a.model_classes }.flatten
    end
  end
end