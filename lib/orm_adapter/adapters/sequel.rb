require 'sequel'

module Sequel
  module Plugins
    module OrmAdapter 
      # The OrmAdapter plugin requires the subclasses plugin to get a list
      # of subclasses, the active_model plugin for ActiveModel compliance,
      # and the instance_hooks plugin to support association= for one_to_many
      # associations.
      def self.apply(model)
        model.plugin :subclasses
        model.plugin :active_model
        model.plugin :instance_hooks
      end

      module ClassMethods
        include ::OrmAdapter::ToAdapter

        # Add an association= method for one_to_many associations that
        # associates each object in the given array to the object after
        # saving.
        def def_one_to_many(opts)
          s = super
          unless opts[:type] == :one_to_one
            association_module_def(opts.setter_method) do |objs|
              after_save_hook{objs.each{|obj| send(opts.add_method, obj)}}
            end
          end
          s
        end
      end
    end
  end

  class Model
    plugin Plugins::OrmAdapter
  
    class OrmAdapter < ::OrmAdapter::Base

      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        ::Sequel::Model.descendents.select{|k| !except_classes.include?(k.name)}
      end

      # get a list of column names for a given class
      def column_names
        klass.columns
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        klass[id] || raise(::Sequel::Error, "no record with primary key #{id.inspect} found")
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass[id]
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.filter(conditions).order(*order_clause(order)).first
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.filter(conditions).order(*order_clause(order)).all
      end
    
      # @see OrmAdapter::Base#create!
      def create!(attributes)
        klass.create(attributes)
      end
      
    protected
      
      def order_clause(order)
        order.map {|pair| Sequel.send(pair.last, pair.first)}
      end
    end
  end
end
