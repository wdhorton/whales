module WhalesORM
  class IncludeRelation < BasicObject
    def initialize(class_name, sym_to_include, association)
      @query = <<-SQL
        SELECT
          #{class_name.table_name}.*
        FROM
          #{class_name.table_name}
        LEFT OUTER JOIN
          #{association.table_name}
        ON
          #{class_name.table_name}.#{association.primary_key} = #{association.table_name}.#{association.foreign_key}
      SQL
      @class_name = class_name
    end

    def method_missing(method, *args, &blk)
      results = self.execute
      results.send(method, *args, &blk)
    end

    def load
      execute
    end

    def execute
      results = ::DBConnection.execute(@query)
      @class_name.parse_all(results)
    end
  end
end
