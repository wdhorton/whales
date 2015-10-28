require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # unless [through_options, source_options].all? { |opt| opt.is_a?(BelongsToOptions) }
    #   raise "has_one_through must use two belongs_to relations!"
    # end

      has_one_or_many_through(name, through_name, source_name, one: true)
  end
end
