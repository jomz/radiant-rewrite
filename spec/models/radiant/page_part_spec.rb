require 'rails_helper'

module Radiant
  RSpec.describe PagePart, type: :model do
    let(:part){ build :page_part }
  
    describe 'name' do
      it 'is invalid when longer than 100 characters' do
        part.name = 'x' * 101
        expect(part).to_not be_valid
        expect(part.errors[:name]).to include("is too long (maximum is 100 characters)")
      end

      it 'is invalid when blank' do
        part.name = ''
        expect(part).to_not be_valid
        expect(part.errors[:name]).to include("can't be blank")
      end
    end
  end
end
