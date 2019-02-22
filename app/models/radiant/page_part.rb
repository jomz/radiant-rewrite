module Radiant
  class PagePart < ApplicationRecord
    belongs_to :page

    # Validations
    validates_presence_of :name
    validates_length_of :name, maximum: 100
    validates_length_of :filter_id, maximum: 25, allow_nil: true
  end
end
