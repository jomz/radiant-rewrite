module Radiant
  class Page < ApplicationRecord
    has_many :parts, ->{ order(:id) }, class_name: 'Radiant::PagePart', dependent: :destroy
    accepts_nested_attributes_for :parts, allow_destroy: true

    validates :title, presence: true, length: { maximum: 255 }
    validates :slug, presence: true, length: { maximum: 100 }, format: %r{\A([-_.A-Za-z0-9]*|/)\z}, uniqueness: { scope: :parent_id }
    validates :breadcrumb, presence: true, length: { maximum: 160 }
    validates :status_id, presence: true

    validate :valid_class_name
    
    def self.is_descendant_class_name?(class_name)
      (Radiant::Page.descendants.map(&:to_s) + [nil, "", "Page"]).include?(class_name)
    end

    def status
      Radiant::Status.find(self.status_id)
    end

    def status=(value)
      Radiant::self.status_id = value.id
    end

    private

    def valid_class_name
      unless Radiant::Page.is_descendant_class_name?(class_name)
        errors.add :class_name, "must be set to a valid descendant of Page"
      end
    end

  end
end
