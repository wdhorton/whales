require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    ::Relation.new(params, self)
  end

  def includes(sym_to_include)
    association = self.assoc_options[sym_to_include]
    if association
      IncludeRelation.new(self, sym_to_include, association)
    end
  end
end

# class IncludeRelation < BasicObject
#   def initialize(class_name, sym_to_include, association)
#     @query = <<-SQL
#       SELECT
#         #{class_name.table_name}.*
#       FROM
#         #{class_name.table_name}
#       LEFT OUTER JOIN
#         #{association.table_name}
#       ON
#         #{class_name.table_name}.#{association.primary_key} = #{association.table_name}.#{association.foreign_key}
#     SQL
#   end
#
#   def execute
#
#   end
# end

class Relation < BasicObject

  def initialize(params, class_name)
    @params = params
    @class_name = class_name
  end

  def where(params)
    @params.merge(params)
  end

  def where_line
    @params.keys.map { |key| "#{key} = ?" }.join(" AND ")
  end

  def method_missing(method, *args, &blk)
    results = self.execute
    results.send(method, *args, &blk)
  end

  def load
    execute
  end

  def execute
    query = <<-SQL
      SELECT
        *
      FROM
        #{@class_name.table_name}
      WHERE
        #{where_line}
    SQL

    results = ::DBConnection.execute(query, *@params.values)
    @class_name.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
