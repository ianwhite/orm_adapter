module OrmAdapter
  # Extend into a class that has an OrmAdapter
  module ToAdapter
    def to_adapter(scope = {})
      self::OrmAdapter.new(self, scope)
    end
  end

end