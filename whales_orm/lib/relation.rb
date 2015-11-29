require_relative './db_connection.rb'

module WhalesORM
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
end
