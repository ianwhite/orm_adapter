module OrmAdapter
  # extend into a class that has an OrmAdapter
  module ToAdapter
    def to_adapter
      @_adapter_instance ||= OrmAdapter.for(self)
    end
  end
end