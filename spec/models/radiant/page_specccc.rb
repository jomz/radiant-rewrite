require 'spec_helper'

describe Radiant::Page, type: :model do
  test_helper :page

  let(:page){ FactoryGirl.build(:page) }

  describe 'breadcrumb' do

    it 'is invalid when longer than 160 characters' do
      page.breadcrumb = 'x' * 161
      expect(page.errors_on(:breadcrumb)).to include('this must not be longer than 160 characters')
    end

    it 'is invalid when blank' do
      page.breadcrumb = ''
      expect(page.errors_on(:breadcrumb)).to include("this must not be blank")
    end

    it 'is valid when 160 characters or shorter' do
      page.breadcrumb = 'x' * 160
      expect(page.errors_on(:breadcrumb)).to be_blank
    end

  end

  describe 'slug' do

    it 'is invalid when longer than 100 characters' do
      page.slug = 'x' * 101
      expect(page.errors_on(:slug)).to include('this must not be longer than 100 characters')
    end

    it 'is invalid when blank' do
      page.slug = ''
      expect(page.errors_on(:slug)).to include("this must not be blank")
    end

    it 'is valid when 100 characters or shorter' do
      page.slug = 'x' * 100
      expect(page.errors_on(:slug)).to be_blank
    end

    it 'is invalid when in the incorrect format' do
      ['this does not match the expected format', 'abcd efg', ' abcd', 'abcd/efg'].each do |sample|
        page.slug = sample
        expect(page.errors_on(:slug)).to include('this does not match the expected format')
      end
    end

    it 'is invalid when the same value exists with the same parent' do
      page.parent_id = 1
      page.save!
      other = Page.new(page_params.merge(parent_id: 1))
      expect{other.save!}.to raise_error(ActiveRecord::RecordInvalid)
      expect(other.errors_on(:slug)).to include(I18n.t('activerecord.errors.models.page.attributes.slug.taken'))
    end

  end

  describe 'title' do

    it 'is invalid when longer than 255 characters' do
      page.title = 'x' * 256
      expect(page.errors_on(:title)).to include('this must not be longer than 255 characters')
    end

    it 'is invalid when blank' do
      page.title = ''
      expect(page.errors_on(:title)).to include("this must not be blank")
    end

    it 'is valid when 255 characters or shorter' do
      page.title = 'x' * 255
      expect(page.errors_on(:title)).to be_blank
    end

  end

  describe 'class_name' do
    it 'should allow mass assignment for class name' do
      page.attributes = { class_name: 'PageSpecTestPage' }
      expect(page.errors_on(:class_name)).to be_blank
      expect(page.class_name).to be_eql('PageSpecTestPage')
    end

    it 'should not be valid when class name is not a descendant of page' do
      page.class_name = 'Object'
      expect(page.errors_on(:class_name)).to include('must be set to a valid descendant of Page')
    end

    it 'should not be valid when class name is not a descendant of page and it is set through mass assignment' do
      page.attributes = {class_name: 'Object' }
      expect(page.errors_on(:class_name)).to include('must be set to a valid descendant of Page')
    end

    it 'should be valid when class name is page or empty or nil' do
      [nil, '', 'Page'].each do |value|
        page = PageSpecTestPage.new(page_params)
        page.class_name = value
        expect(page.errors_on(:class_name)).to be_blank
        expect(page.class_name).to be_eql(value)
      end
    end
  end
end