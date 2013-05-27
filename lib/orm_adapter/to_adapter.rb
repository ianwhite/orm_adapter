module OrmAdapter
  # Extend into a class that has an OrmAdapter
  module ToAdapter
    def to_adapter
      @_to_adapter ||= self::OrmAdapter.new(self)
    end
  end

  module ToCollectionAdapter
    def to_adapter
      @_to_adapter ||= self.class::OrmAdapter.new(self)
    end
  end
end