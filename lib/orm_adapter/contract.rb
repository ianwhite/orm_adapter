module OrmAdapter
  # override these class methods on your orm adapter 
  module Contract
    # Gets a list of the available models for this adapter
    def model_classes
      raise NotImplementedError, "return a list of available models for this adapter"
    end

    # Get an instance by id of the model
    def get_model(klass, id)
      raise NotSupportedError
    end

    # Find the first instance matching conditions
    def find_first_model(klass, conditions)
      raise NotSupportedError
    end

    # Find all models matching conditions
    def find_all_models(klass, conditions)
      raise NotSupportedError
    end

    # Create a model using attributes
    def create_model(klass, attributes)
      raise NotSupportedError
    end
  end

  class NotSupportedError < RuntimeError
    def to_s
      "method not supported by this orm adapter"
    end
  end
end