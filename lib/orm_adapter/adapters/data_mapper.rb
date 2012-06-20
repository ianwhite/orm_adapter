require 'dm-core'

module DataMapper
  module Model
    include OrmAdapter::ToAdapter
  end

  module Resource
    class OrmAdapter < ::OrmAdapter::Base
      # get a list of column names for a given class
      def column_names
        klass.properties.map(&:name)
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        klass.get!(id)
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.get(id)
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options = {})
        conditions, order = extract_conditions_and_order!(options)
        klass.first :conditions => conditions, :order => order_clause(order)
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options = {})
        conditions, order = extract_conditions_and_order!(options)
        klass.all :conditions => conditions, :order => order_clause(order)
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes = {})
        klass.create(attributes)
      end

      # @see OrmAdapter::Base#destroy
      def destroy(object)
        object.destroy if valid_object?(object)
      end

    protected

      def order_clause(order)
        order.map {|pair| pair.first.send(pair.last)}
      end
    end
  end
end
