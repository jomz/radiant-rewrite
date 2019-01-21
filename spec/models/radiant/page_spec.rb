require 'rails_helper'

module Radiant
  RSpec.describe Page, type: :model do
    let(:page){ Page.new }
    
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
  end
end
