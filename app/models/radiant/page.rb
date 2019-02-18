module Radiant
  class Page < ApplicationRecord
    validates :title, presence: true, length: { maximum: 255 }
    validates :slug, presence: true, length: { maximum: 100 }, format: %r{\A([-_.A-Za-z0-9]*|/)\z}, uniqueness: { scope: :parent_id }
    validates :breadcrumb, presence: true, length: { maximum: 160 }
    
    def status
     Radiant::Status.find(self.status_id)
    end

    def status=(value)
      Radiant::self.status_id = value.id
    end
  end
end
