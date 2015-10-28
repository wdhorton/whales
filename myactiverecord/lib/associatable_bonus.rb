require_relative '04_associatable2'
require 'byebug'

module Associatable

  private

  def has_one_or_many_through(name, through_name, source_name, type = {})
    keywords = ["primary", "foreign"]
    keywords.sort! if type[:one]

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      opts = [through_options, source_options]

      key_value = send(through_options.send("#{keywords[0]}_key"))
      key_name = through_options.send("#{keywords[1]}_key")
      src_table = source_options.table_name
      thr_table = through_options.table_name

      results = DBConnection.execute(<<-SQL, key_value)
        SELECT
          #{src_table}.*
        FROM
          #{src_table}
        JOIN
          #{thr_table}
        ON
          #{thr_table}.#{source_options.foreign_key} = #{src_table}.#{source_options.primary_key}
        WHERE
          #{thr_table}.#{key_name} = ?
      SQL

      return nil if results.nil? || results.empty?
      send_opts = (type[:one] ? [:new, results.first] : [:parse_all, results])
      source_options.model_class.send(*send_opts)
    end
  end

end
