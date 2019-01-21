module Radiant
  class Page < ApplicationRecord
    validates :breadcrumb, presence: true, length: { maximum: 160 }
  end
end
