require 'dm-core'

module DataMapper
  module Model
    include OrmAdapter::ToAdapter
  end
  
  module Resource
    class OrmAdapter < ::OrmAdapter::Base

      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        ::DataMapper::Model.descendants.to_a.select{|k| !except_classes.include?(k.name)}
      end

      # get a list of column names for a given class
      def column_names
        klass.properties.map(&:name)
      end

      # Get an instance by id of the model
      def get!(id)
        klass.get!(id)
      end

      # Find the first instance matching conditions
      def find_first(conditions)
        klass.first(conditions)
      end

      # Find all models matching conditions
      def find_all(conditions)
        klass.all(conditions)
      end
    
      # Create a model using attributes
      def create!(attributes)
        klass.create(attributes)
      end
    end
  end
end
