module OrmAdapter
  module AdapterMethods
    def find_first(conditions = {})
      model_class.const_get(:OrmAdapter).find_first_model(model_class, conditions)
    end

    def find_all(conditions = {})
      model_class.const_get(:OrmAdapter).find_all_models(model_class, conditions)
    end

    def get(id)
      model_class.const_get(:OrmAdapter).get_model(model_class, id)
    end
  end
end