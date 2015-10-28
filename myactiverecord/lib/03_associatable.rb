require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.each do |k, v|
      send("#{k}=", v)
    end
    @primary_key ||= :id
    @foreign_key ||= "#{name}_id".to_sym
    @class_name ||= name.to_s.camelcase
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options.each do |k, v|
      send("#{k}=", v)
    end
    @primary_key ||= :id
    @foreign_key ||= "#{self_class_name.underscore}_id".to_sym
    @class_name ||= name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    opts = BelongsToOptions.new(name.to_s, options)

    define_method(name) do
      foreign_key = send(opts.foreign_key)
      opts.model_class.where(opts.primary_key => foreign_key).first
    end

    assoc_options[name] = opts
  end

  def has_many(name, options = {})
    if options[:through]
      has_one_or_many_through(name, options[:through], options[:source])
    else
      opts = HasManyOptions.new(name.to_s, self.to_s, options)

      define_method(name) do
        primary_key_value = send(opts.primary_key)
        where_clause = {opts.foreign_key => primary_key_value}
        opts.model_class.where(where_clause)
      end

      assoc_options[name] = opts
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
