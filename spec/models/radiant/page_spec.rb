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
  end
end
