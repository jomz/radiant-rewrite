module Radiant
  class Page < ApplicationRecord
    include ActsAsTree
    acts_as_tree
    class MissingRootPageError < StandardError
      def initialize(message = 'Database missing root page'); super end
    end
    
    has_many :parts, ->{ order(:id) }, class_name: 'Radiant::PagePart', dependent: :destroy
    accepts_nested_attributes_for :parts, allow_destroy: true

    validates :title, presence: true, length: { maximum: 255 }
    validates :slug, presence: true, length: { maximum: 100 }, format: %r{\A([-_.A-Za-z0-9]*|/)\z}, uniqueness: { scope: :parent_id }
    validates :breadcrumb, presence: true, length: { maximum: 160 }
    validates :status_id, presence: true
    validate :valid_class_name
    
    self.inheritance_column = 'class_name'
    
    def child_path(child)
      clean_path(path + '/' + child.slug)
    end
    
    def clean_path(path)
      "/#{ path.to_s.strip }/".gsub(%r{//+}, '/')
    end

    def find_by_path(path, live = true, clean = true)
      return nil if virtual?
      path = clean_path(path) if clean
      my_path = self.path
      if (my_path == path) && (!live or published?)
        self
      elsif (path =~ /^#{Regexp.quote(my_path)}([^\/]*)/)
        slug_child = children.where(slug: $1).first
        if slug_child
          found = slug_child.find_by_path(path, live, clean)
          return found if found
        end
        children.each do |child|
          found = child.find_by_path(path, live, clean)
          return found if found
        end

        if live
          file_not_found_names = ([FileNotFoundPage] + FileNotFoundPage.descendants).map(&:name)
          children.where(status_id: Status[:published].id).where(class_name: file_not_found_names).first
        else
          children.first
        end
      end
    end
    
    def has_part?(name)
      !part(name).nil?
    end

    def has_or_inherits_part?(name)
      has_part?(name) || inherits_part?(name)
    end

    def inherits_part?(name)
      !has_part?(name) && self.ancestors.any? { |page| page.has_part?(name) }
    end

    def self.is_descendant_class_name?(class_name)
      (Radiant::Page.descendants.map(&:to_s) + [nil, "", "Page"]).include?(class_name)
    end
    
    def parent?
      !parent.nil?
    end
    
    def part(name)
      if new_record? or parts.to_a.any?(&:new_record?)
        parts.to_a.find {|p| p.name == name.to_s }
      else
        parts.find_by(name: name.to_s)
      end
    end
    
    def path
      if parent?
        parent.child_path(self)
      else
        clean_path(slug)
      end
    end

    def published?
      status == Status[:published]
    end

    def scheduled?
      status == Status[:scheduled]
    end

    def status
      Radiant::Status.find(self.status_id)
    end

    def status=(value)
      self.status_id = value.id
    end

    def valid_class_name
      unless Radiant::Page.is_descendant_class_name?(class_name)
        errors.add :class_name, "must be set to a valid descendant of Page"
      end
    end

    class << self
      def find_by_path(path, live = true)
        raise MissingRootPageError unless root
        root.find_by_path(path, live)
      end
    end
  end
end
