module Texticle
  class FullTextIndex # :nodoc:
    attr_accessor :index_columns

    def initialize name, model_class, &block
      @name           = name
      @model_class    = model_class
      @index_columns  = {}
      @string         = nil
      instance_eval(&block)
    end

    def create
      @model_class.connection.execute create_sql
    end

    def destroy
      @model_class.connection.execute destroy_sql
    end

    def create_sql
       "ALTER TABLE #{@model_class.table_name} ADD FULLTEXT (#{self.to_s})"
    end

    def destroy_sql
       "ALTER TABLE #{@model_class.table_name} DROP INDEX #{self.columns[0]}"
    end

    def columns
      columns = []
      @index_columns.sort_by { |k,v| v }.reverse.each do |weight, column|
        columns << column 
      end
      columns.flatten      
    end
    
    def to_s
      return @string if @string
      cols = self.columns.collect {|column|
     "`#{column}`"
     }
      cols.join(", ")
    end
    def method_missing name, *args
      weight = args.shift || 'none'
      (index_columns[weight] ||= []) << name.to_s
    end
  end
end
