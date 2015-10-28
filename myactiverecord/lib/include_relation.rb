module MyActiveRecord
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
    end

    def execute

    end
  end
end
