require 'rails_helper'

module Radiant
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
  end
end
