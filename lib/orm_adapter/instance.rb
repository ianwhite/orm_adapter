module OrmAdapter
  class Instance
    attr_reader :klass
  
    def initialize(klass)
      @klass = klass
    end

    def find_first(conditions = {})
      klass.const_get(:OrmAdapter).find_first_model(klass, conditions)
    end

    def find_all(conditions = {})
      klass.const_get(:OrmAdapter).find_all_models(klass, conditions)
    end

    def get(id)
      klass.const_get(:OrmAdapter).get_model(model_class, id)
    end
  end
end