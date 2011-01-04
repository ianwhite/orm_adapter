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

    # Get a list of column/property/field names
    def column_names
      raise NotSupportedError
    end
    
    # Get an instance by id of the model. Raises an error if a model is not found.
    # This should comply with ActiveModel#to_key API, i.e.:
    #
    #   User.to_adapter.get!(@user.to_key) == @user
    #
    def get!(id)
      raise NotSupportedError
    end

    # Get an instance by id of the model. Returns nil if a model is not found.
    # This should comply with ActiveModel#to_key API, i.e.:
    #
    #   User.to_adapter.get(@user.to_key) == @user
    #
    def get
      raise NotSupportedError
    end

    # Find the first instance, optionally matching conditions, and specifying order
    #
    #  User.to_adapter.find_first :name => "Fred"
    #  User.to_adapter.find_first :order => :name
    #  User.to_adapter.find_first :conditions => {:name => "Fred"}, :order => [:last_seen, :desc]
    #  User.to_adapter.find_first :order => [:name, [:last_seen, :desc]]
    #
    def find_first(conditions)
      raise NotSupportedError
    end

    # Find all models, optionally matching conditions, and specifying order
    #
    #  User.to_adapter.find_all :name => "Fred"
    #  User.to_adapter.find_all :order => :name
    #  User.to_adapter.find_all :conditions => {:name => "Fred"}, :order => [:last_seen, :desc]
    #  User.to_adapter.find_all :order => [:name, [:last_seen, :desc]]
    #
    def find_all(conditions)
      raise NotSupportedError
    end

    # Create a model using attributes
    def create!(attributes)
      raise NotSupportedError
    end

    protected

    def wrap_key(key)
      key.is_a?(Array) ? key.first : key
    end
    
    # given an options hash, with optional :conditions and :order keys, returns conditions and normalized order
    def extract_conditions_and_order!(options = {})
      order = normalize_order(options.delete(:order))
      conditions = options.delete(:conditions) || options
      [conditions, order]
    end
    
    # given an order argument, returns an array of pairs, with each pair containing the attribute, and :asc or :desc
    def normalize_order(order)
      order = Array(order)
      
      if order.length == 2 && !order[0].is_a?(Array) && [:asc, :desc].include?(order[1])
        order = [order]
      else
        order = order.map {|pair| pair.is_a?(Array) ? pair : [pair, :asc] }
      end
      
      order.each do |pair|
        pair.length == 2 or raise ArgumentError, "each order clause must be a pair (unknown clause #{pair.inspect})"
        [:asc, :desc].include?(pair[1]) or raise ArgumentError, "order must be specified with :asc or :desc (unknown key #{pair[1].inspect})"
      end
      
      order
    end
  end

  class NotSupportedError < NotImplementedError
    def to_s
      "method not supported by this orm adapter"
    end
  end
end