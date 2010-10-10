begin
  require 'activerecord'
rescue LoadError
  require 'active_record'
end

class ActiveRecord::Base
  extend OrmAdapter::ToAdapter
  
  class OrmAdapter < ::OrmAdapter::Base

    # Do not consider these to be part of the class list
    def self.except_classes
      @@except_classes ||= [
        "CGI::Session::ActiveRecordStore::Session",
        "ActiveRecord::SessionStore::Session"
      ]
    end

    # Gets a list of the available models for this adapter
    def self.model_classes
      begin
        klasses = ::ActiveRecord::Base.__send__(:descendants) # Rails 3
      rescue
        klasses = ::ActiveRecord::Base.__send__(:subclasses) # Rails 2
      end

      klasses.select do |klass|
        !klass.abstract_class? && !except_classes.include?(klass.name)
      end
    end

    # Return list of column/property names
    def column_names
      klass.column_names
    end

    # Get an instance by id of the model
    def get!(id)
      klass.find(wrap_key(id))
    end

    # Get an instance by id of the model
    def get(id)
      klass.first :conditions => { klass.primary_key => wrap_key(id) }
    end

    # Find the first instance matching conditions
    def find_first(conditions)
      klass.first :conditions => conditions_to_fields(conditions)
    end

    # Find all models matching conditions
    def find_all(conditions)
      klass.all :conditions => conditions_to_fields(conditions)
    end
    
    # Create a model using attributes
    def create!(attributes)
      klass.create!(attributes)
    end
    
  protected

    # Introspects the klass to convert and objects in conditions into foreign key and type fields
    def conditions_to_fields(conditions)
      conditions.inject({}) do |fields, (key, value)|
        if value.is_a?(ActiveRecord::Base) && klass.column_names.include?("#{key}_id")
          if klass.column_names.include?("#{key}_type")
            fields.merge("#{key}_id" => value.id, "#{key}_type" => value.class.base_class.name)
          else
            fields.merge("#{key}_id" => value.id)
          end
        else
          fields.merge(key => value)
        end
      end
    end
  end
end
