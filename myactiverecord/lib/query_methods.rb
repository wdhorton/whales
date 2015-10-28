module MyActiveRecord
  module QueryMethods
    def where(params)
      MyActiveRecord::Relation.new(params, self)
    end

    def includes(sym_to_include)
      association = self.assoc_options[sym_to_include]
      if association
        MyActiveRecord::IncludeRelation.new(self, sym_to_include, association)
      end
    end
  end
end
