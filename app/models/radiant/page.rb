module Radiant
  class Page < ApplicationRecord
    include ActsAsTree
    acts_as_tree
    class MissingRootPageError < StandardError
      def initialize(message = 'Database missing root page'); super end
    end

    before_save :update_status

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

    def headers
      # Return a blank hash that child classes can override or merge
      { }
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

    def process(request, response)
      @request, @response = request, response
      set_response_headers(@response)
      @response.body = render
      @response.status = response_code
    end

    def render
      # if layout
        # parse_object(layout)
      # else
        render_part(:body)
      # end
    end

    def render_part(part_name)
      part = part(part_name)
      if part
        parse_object(part)
      else
        ''
      end
    end

    def response_code
      200
    end

    def set_response_headers(response)
      # set_content_type(response)
      headers.each{|k,v| response.headers[k] = v }
    end
    private :set_response_headers

    # def set_content_type(response)
    #   if layout
    #     if content_type = layout.content_type.to_s.strip
    #       response.headers['Content-Type'] = content_type
    #     end
    #   end
    # end
    # private :set_content_type

    def scheduled?
      status == Status[:scheduled]
    end

    def status
      Radiant::Status.find(self.status_id)
    end

    def status=(value)
      self.status_id = value.id
    end

    def update_status
      self.published_at = Time.zone.now if published? && self.published_at == nil

      if self.published_at != nil && (published? || scheduled?)
        self[:status_id] = Status[:scheduled].id if self.published_at  > Time.zone.now
        self[:status_id] = Status[:published].id if self.published_at <= Time.zone.now
      end

      true
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

    private

    # def lazy_initialize_parser_and_context
    #   unless @parser and @context
    #     @context = PageContext.new(self)
    #     @parser = Radius::Parser.new(@context, tag_prefix: 'r')
    #   end
    #   @parser
    # end
    #
    # def parse(text)
    #   lazy_initialize_parser_and_context(text)
    # end

    def parse_object(object)
      text = object.content || ''
      # text = parse(text)
      # text = object.filter.filter(text) if object.respond_to? :filter_id
      text
    end
  end
end
