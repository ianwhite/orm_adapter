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
      def get!(*id)
        get(*id) || raise(DataMapper::ObjectNotFoundError)
      end

      # @see OrmAdapter::Base#get
      def get(*id)
        if @scope.empty?
          klass.get(*id)
        else
          primary_key_conditions = klass.key_conditions(klass.repository, klass.key(klass.repository.name).typecast(id)).update(:order => nil)
          klass.first(@scope.merge(primary_key_conditions))
        end
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options = {})
        conditions, order = extract_conditions!(options)
        klass.first(scoped_query.update(:conditions => conditions, :order => order_clause(order)))
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options = {})
        conditions, order, limit, offset = extract_conditions!(options)
        opts = { :conditions => conditions, :order => order_clause(order) }
        opts = opts.merge({ :limit => limit }) unless limit.nil?
        opts = opts.merge({ :offset => offset }) unless offset.nil?
        klass.all(scoped_query.update(opts))
      end

      # @see OrmAdapter::Base#build
      def build(attributes = {})
        klass.new(@scope.merge(attributes))
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes = {})
        klass.create(@scope.merge(attributes))
      end

      # @see OrmAdapter::Base#destroy
      def destroy(object)
        object.destroy if valid_object?(object)
      end

    protected

      def scoped_query
        klass.all(@scope).query
      end

      def order_clause(order)
        order.map {|pair| pair.first.send(pair.last)}
      end
    end
  end
end
