require 'mongoid'

module Mongoid
  module Document
    module ClassMethods
      include OrmAdapter::ToAdapter
    end
    
    class OrmAdapter < ::OrmAdapter::Base
      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        ObjectSpace.each_object(Class).to_a.select {|klass| klass.ancestors.include? Mongoid::Document}
      end

      # get a list of column names for a given class
      def column_names
        klass.fields.keys
      end

      # Get an instance by id of the model
      def get_model(id)
        klass.find(id)
      end

      # Find the first instance matching conditions
      def find_first_model(conditions)
        klass.first(:conditions => conditions_to_fields(conditions))
      end

      # Find all models matching conditions
      def find_all_models(conditions)
        klass.all(:conditions => conditions_to_fields(conditions))
      end

      # Create a model with given attributes
      def create_model(attributes)
        klass.create!(attributes)
      end
  
    protected

      # converts and documents to ids
      def conditions_to_fields(conditions)
        conditions.inject({}) do |fields, (key, value)|
          if value.is_a?(Mongoid::Document) && klass.fields.keys.include?("#{key}_id")
            fields.merge("#{key}_id" => value.id)
          else
            fields.merge(key => value)
          end
        end
      end
    end
  end
end
