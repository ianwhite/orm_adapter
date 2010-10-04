module OrmAdapter
  # extend into a class that has an OrmAdapter
  module ToAdapter
    def to_adapter
      @_adapter_instance ||= ::OrmAdapter::Instance.new(self)
    end
  end
end