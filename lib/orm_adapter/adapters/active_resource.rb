begin
  require 'activeresource'
rescue LoadError
  require 'active_resource'
end

class ActiveResource::Base
  extend OrmAdapter::ToAdapter
  
  class OrmAdapter < ::OrmAdapter::Base
    # Do not consider these to be part of the class list
    def self.except_classes
      @@except_classes ||= []
    end

    # Gets a list of the available models for this adapter
    def self.model_classes
      begin
        klasses = ::ActiveResource::Base.__send__(:descendants) # Rails 3
      rescue
        klasses = ::ActiveResource::Base.__send__(:subclasses) # Rails 2
      end

      klasses.select do |klass|
        !except_classes.include?(klass.name)
      end
    end

    # Return list of column/property names
    def column_names
      klass.column_names
    end

    # @see OrmAdapter::Base#get!
    def get!(id)
      klass.find(wrap_key(id))
    end

    # @see OrmAdapter::Base#get
    def get(id)
      klass.find(:first, :params => {:id => wrap_key(id)})
    end

    # @see OrmAdapter::Base#find_first
    def find_first(options)
      conditions, order = extract_conditions_and_order!(options)
      klass.find(:first, :params => conditions_to_fields(conditions).merge(order_clause(order)))
    end

    # @see OrmAdapter::Base#find_all
    def find_all(options)
      conditions, order = extract_conditions_and_order!(options)
      klass.find(:all, :params => conditions_to_fields(conditions).merge(order_clause(order)))
    end
    
    # @see OrmAdapter::Base#create!
    def create!(attributes)
      klass.create(attributes)
    end
    
  protected
    # Introspects the klass to convert and objects in conditions into foreign key and type fields
    def conditions_to_fields(conditions)
      fields = {}
      conditions.each do |key, value|
        if !klass.schema[key] && klass.schema[key.to_s + "_id"]
          fields[key.to_s + "_id"] = value
        else
          fields[key] = value
        end
      end
      fields
    end
    
    def order_clause(order)
      {:order => order.map {|pair| "#{pair[0]} #{pair[1]}"}.join(",")}
    end
  end
end
