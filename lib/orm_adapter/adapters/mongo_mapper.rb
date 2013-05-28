require 'mongo_mapper'

module MongoMapper
  module Document
    module ClassMethods
      include OrmAdapter::ToAdapter
    end

    class OrmAdapter < ::OrmAdapter::Base
      # get a list of column names for a given class
      def column_names
        klass.column_names
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        scoped.find!(wrap_key(id))
      end

      # @see OrmAdapter::Base#get
      def get(id)
        scoped.first({ :id => wrap_key(id) })
      end

      # @see OrmAdapter::Base#find_first
      def find_first(conditions = {})
        conditions, order = extract_conditions!(conditions)
        conditions = conditions.merge(:sort => order) unless order.nil?
        scoped.first(conditions_to_fields(conditions))
      end

      # @see OrmAdapter::Base#find_all
      def find_all(conditions = {})
        conditions, order, limit, offset = extract_conditions!(conditions)
        conditions = conditions.merge(:sort => order) unless order.nil?
        conditions = conditions.merge(:limit => limit) unless limit.nil?
        conditions = conditions.merge(:offset => offset) unless limit.nil? || offset.nil?
        scoped.all(conditions_to_fields(conditions))
      end

      # @see OrmAdapter::Base#build
      def build(attributes = {})
        klass.new(@scope.merge(attributes))
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes = {})
        klass.create!(@scope.merge(attributes))
      end

      # @see OrmAdapter::Base#destroy
      def destroy(object)
        object.destroy if valid_object?(object)
      end

    protected

      def scoped
        klass.where(conditions_to_fields(@scope))
      end

      # converts and documents to ids
      def conditions_to_fields(conditions)
        conditions.inject({}) do |fields, (key, value)|
          if value.is_a?(MongoMapper::Document) && klass.key?("#{key}_id")
            fields.merge("#{key}_id" => value.id)
          else
            fields.merge(key => value)
          end
        end
      end
    end
  end
end
