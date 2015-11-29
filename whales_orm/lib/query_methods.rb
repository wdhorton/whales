module WhalesORM
  module QueryMethods
    def where(params)
      WhalesORM::Relation.new(params, self)
    end

    def includes(sym_to_include)
      association = self.assoc_options[sym_to_include]
      if association
        WhalesORM::IncludeRelation.new(self, sym_to_include, association)
      end
    end
  end
end
