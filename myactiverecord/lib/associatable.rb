module MyActiveRecord

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

  class BelongsToOptions < MyActiveRecord::AssocOptions
    def initialize(name, options = {})
      options.each do |k, v|
        send("#{k}=", v)
      end
      @primary_key ||= :id
      @foreign_key ||= "#{name}_id".to_sym
      @class_name ||= name.to_s.camelcase
    end

  end

  class HasManyOptions < MyActiveRecord::AssocOptions
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
    def belongs_to(name, options = {})
      opts = MyActiveRecord::BelongsToOptions.new(name.to_s, options)

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
        opts = MyActiveRecord::HasManyOptions.new(name.to_s, self.to_s, options)

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

    def has_one_through(name, through_name, source_name)
      # unless [through_options, source_options].all? { |opt| opt.is_a?(BelongsToOptions) }
      #   raise "has_one_through must use two belongs_to relations!"
      # end

        has_one_or_many_through(name, through_name, source_name, one: true)
    end

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

end
