require 'active_record'

module OrmAdapter
  class ActiveRecord < Base
    # Return list of column/property names
    def column_names
      klass.column_names
    end

    def get!(id)
      klass.find(id)
    end  
    
    # @see OrmAdapter::Base#get
    def get(id)
      
      record = nil
      new_id =  (id.is_a?(Array) && id.length == 1) ? id[0] : id

      if new_id && new_id.is_a?(String) && new_id.length == 24
        record = klass.find_by_old_id(new_id)
      else
        record = klass.find_by_num_id(new_id)
      end  
      
      if record && record.is_a?(Array)
        return record.first
      else
        return record
      end  
    end

    # @see OrmAdapter::Base#find_first
    def find_first(options = {})
      construct_relation(klass, options).first
    end


  protected
    def construct_relation(relation, options)
      conditions, order, limit, offset = extract_conditions!(options)

      relation = relation.where(conditions_to_fields(conditions))
      relation = relation.order(order_clause(order)) if order.any?
      relation = relation.limit(limit) if limit
      relation = relation.offset(offset) if offset

      relation
    end

    # Introspects the klass to convert and objects in conditions into foreign key and type fields
    def conditions_to_fields(conditions)
      fields = {}
      conditions.each do |key, value|
        if value.is_a?(::ActiveRecord::Base) && (assoc = klass.reflect_on_association(key.to_sym)) && assoc.belongs_to?

          if ::ActiveRecord::VERSION::STRING < "3.1"
            fields[assoc.primary_key_name] = value.send(value.class.primary_key)
            fields[assoc.options[:foreign_type]] = value.class.base_class.name.to_s if assoc.options[:polymorphic]
          else # >= 3.1
            fields[assoc.foreign_key] = value.send(value.class.primary_key)
            fields[assoc.foreign_type] = value.class.base_class.name.to_s if assoc.options[:polymorphic]
          end

        else
          fields[key] = value
        end
      end
      fields
    end

    def order_clause(order)
      order.map {|pair| "#{pair[0]} #{pair[1]}"}.join(",")
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend ::OrmAdapter::ToAdapter
  self::OrmAdapter = ::OrmAdapter::ActiveRecord
end
