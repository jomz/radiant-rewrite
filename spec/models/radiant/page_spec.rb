require 'rails_helper'

module Radiant
  class PageSpecTestPage < Radiant::Page
  end
  
  RSpec.describe Page, type: :model do
    let(:page){ build :page }
    
    describe 'breadcrumb' do
      it 'is invalid when longer than 160 characters' do
        page.breadcrumb = 'x' * 161
        expect(page).to_not be_valid
        expect(page.errors[:breadcrumb]).to include("is too long (maximum is 160 characters)")
      end

      it 'is invalid when blank' do
        page.breadcrumb = ''
        expect(page).to_not be_valid
        expect(page.errors[:breadcrumb]).to include("can't be blank")
      end

      it 'is valid when 160 characters or shorter' do
        page.breadcrumb = 'x' * 160
        expect(page).to be_valid
        expect(page.errors[:breadcrumb]).to be_blank
      end
    end
    
    describe 'slug' do
      it 'is invalid when longer than 100 characters' do
        page.slug = 'x' * 101
        expect(page).to_not be_valid
        expect(page.errors[:slug]).to include('is too long (maximum is 100 characters)')
      end

      it 'is invalid when blank' do
        page.slug = ''
        expect(page).to_not be_valid
        expect(page.errors[:slug]).to include("can't be blank")
      end

      it 'is valid when 100 characters or shorter' do
        page.slug = 'x' * 100
        expect(page).to be_valid
        expect(page.errors[:slug]).to be_blank
      end

      it 'is invalid when in the incorrect format' do
        ['this does not match the expected format', 'abcd efg', ' abcd', 'abcd/efg'].each do |sample|
          page.slug = sample
          expect(page).to_not be_valid
          expect(page.errors[:slug]).to include('is invalid')
        end
      end

      it 'is invalid when the same value exists with the same parent' do
        page.parent_id = 1
        page.save!
        other = Page.new(attributes_for(:page).merge(parent_id: 1))
        expect{other.save!}.to raise_error(ActiveRecord::RecordInvalid)
        expect(other.errors[:slug]).to include('has already been taken')
      end
    end
    
    describe 'title' do
      it 'is invalid when longer than 255 characters' do
        page.title = 'x' * 256
        expect(page).to_not be_valid
        expect(page.errors[:title]).to include('is too long (maximum is 255 characters)')
      end

      it 'is invalid when blank' do
        page.title = ''
        expect(page).to_not be_valid
        expect(page.errors[:title]).to include("can't be blank")
      end

      it 'is valid when 255 characters or shorter' do
        page.title = 'x' * 255
        expect(page).to be_valid
        expect(page.errors[:title]).to be_blank
      end
    end
    
    describe 'class_name' do
      it 'should allow mass assignment for class name' do
        page.attributes = { class_name: 'Radiant::PageSpecTestPage' }
        expect(page).to be_valid
        expect(page.errors[:class_name]).to be_blank
        expect(page.class_name).to be_eql('Radiant::PageSpecTestPage')
      end

      it 'should not be valid when class name is not a descendant of page' do
        page.class_name = 'Object'
        expect(page).to_not be_valid
        expect(page.errors[:class_name]).to include('must be set to a valid descendant of Page')
      end

      it 'should not be valid when class name is not a descendant of page and it is set through mass assignment' do
        page.attributes = { class_name: 'Object' }
        expect(page).to_not be_valid
        expect(page.errors[:class_name]).to include('must be set to a valid descendant of Page')
      end

      it 'should be valid when class name is page or empty or nil' do
        [nil, '', 'Page'].each do |value|
          page.class_name = value
          expect(page).to be_valid
          expect(page.errors[:class_name]).to be_blank
          expect(page.class_name).to be_eql(value)
        end
      end
    end
    
    describe '#path' do

      let(:home){ build(:page, slug: '/', published_at: Time.now) }
      let(:parent){ build(:page, parent: home, slug: 'parent', published_at: Time.now) }
      let(:child){ build(:page, parent: parent, slug: 'child', published_at: Time.now) }
      let(:grandchild){ build(:page, parent: child, slug: 'grandchild', published_at: Time.now) }

      it "should start with a slash" do
        expect(home.path).to match(/\A\//)
      end
      it "should return a string with the current page's slug catenated with it's ancestor's slugs and delimited by slashes" do
        expect(grandchild.path).to eq('/parent/child/grandchild/')
      end
      it 'should end with a slash' do
        expect(page.path).to match(/\/\z/)
      end
    end
    
    describe '#parts' do
      it 'should return PageParts with a page_id of the page id' do
        page.save
        page.parts.create(name: 'body')
        page.parts.create(name: 'sidebar')
        expect(page.parts.sort_by{|p| p.name }).to eq(Radiant::PagePart.where(page_id: page.id).sort_by{|p| p.name })
      end
    end
    
    it 'should destroy dependant parts' do
      page.save
      page.parts.create(name: 'test')
      expect(page.parts.find_by_name('test')).not_to be_nil
      id = page.id
      page.destroy
      expect(Radiant::PagePart.find_by_page_id(id)).to be_nil
    end
    
    describe '#part' do
      before do
        page.save
        page.parts.create(name: 'body')
      end
      it 'should find the part with a name of the given string' do
        expect(page.part('body')).to eq(page.parts.find_by_name('body'))
      end
      it 'should find the part with a name of the given symbol' do
        expect(page.part(:body)).to eq(page.parts.find_by_name('body'))
      end
      it 'should access unsaved parts by name' do
        part = page.parts.build name: 'test'
        expect(page.part('test')).to eq(part)
        expect(page.part(:test)).to eq(part)
      end
      it 'should return nil for an invalid part name' do
        expect(page.part('not-real')).to be_nil
      end
    end
  end
end
