require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2("SELECT * FROM #{table_name} LIMIT 1")[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=".to_sym) do |value|
        attributes[col] = value
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.instance.get_first_row(<<-SQL, id: id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = :id
    SQL

    result ? self.new(result) : nil
  end

  def initialize(params = {})
    params.each do |k, v|
      attr_name = k.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr_name| send(attr_name) }
  end

  def insert
    col_names = self.class.columns.drop(1).join(',')
    question_marks = (["?"] * (self.class.columns.length - 1)).join(',')

    DBConnection.execute(<<-SQL, *(attribute_values.drop(1)))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks});
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map { |attr_name| "#{attr_name} = ?" }
    set_line = set_line.join(', ')

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL

  end

  def save
    id.nil? ? insert : update
  end
end
