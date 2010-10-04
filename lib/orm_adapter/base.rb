module OrmAdapter
  class Base
    attr_reader :klass

    # Your ORM adapter needs to inherit from this Base class and its adapter
    # will be registered. To create an adapter you should create an inner
    # constant "OrmAdapter" e.g. ActiveRecord::Base::OrmAdapter
    #
    # @see orm_adapters/active_record
    # @see orm_adapters/datamapper
    # @see orm_adapters/mongoid
    def self.inherited(adapter)
      OrmAdapter.adapters << adapter
      super
    end

    # Gets a list of the available models for this adapter
    def self.model_classes
      raise NotImplementedError, "return a list of available models for this adapter"
    end

    def initialize(klass)
      @klass = klass
    end

    # Get an instance by id of the model
    def get_model(id)
      raise NotSupportedError
    end

    # Find the first instance matching conditions
    def find_first_model(conditions)
      raise NotSupportedError
    end

    # Find all models matching conditions
    def find_all_models(conditions)
      raise NotSupportedError
    end

    # Create a model using attributes
    def create_model(attributes)
      raise NotSupportedError
    end
  end

  class NotSupportedError < RuntimeError
    def to_s
      "method not supported by this orm adapter"
    end
  end
end