require 'mongo_mapper'

MongoMapper::Document.append_extensions(OrmAdapter::ToAdapter)

module MongoMapper
  module Document
    
    class OrmAdapter < ::OrmAdapter::Base
      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        MongoMapper::Document.descendants.to_a.select{|k| !except_classes.include?(k.name)}
      end

      # get a list of column names for a given class
      def column_names
        klass.keys.keys
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        klass.find!(wrap_key(id))
      rescue BSON::InvalidObjectId
        raise MongoMapper::DocumentNotFound
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.find(wrap_key(id))
        rescue BSON::InvalidObjectId
        nil
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.where(conditions_to_fields(conditions)).order(order).first
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.where(conditions_to_fields(conditions)).order(order).all
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes)
        klass.create!(attributes)
      end
  
    protected

      # converts and documents to ids
      def conditions_to_fields(conditions)
        conditions.inject({}) do |fields, (key, value)|
          if MongoMapper::Document.descendants.include?(value.class) && klass.keys.keys.include?("#{key}_id")
            fields.merge("#{key}_id" => value.id)
          else
            fields.merge(key => value)
          end
        end
      end
    end
  end
end
