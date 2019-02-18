require 'rails_helper'

module Radiant
  RSpec.describe Status, "attributes" do
    before :all do
      @status = Radiant::Status.new(id: 1, name: 'Test')
    end
  
    specify 'id' do
      expect(@status.id).to eq(1)
    end
  
    specify 'symbol' do
      expect(@status.name).to eq('Test')
    end
  
    specify 'name' do
      expect(@status.symbol).to eq(:test)
    end
  end

  RSpec.describe Status, 'find' do
    it 'should find by number ID' do
      expect(Radiant::Status.find(1).id).to eq(1)
    end
  
    it 'should find by string ID' do
      expect(Radiant::Status.find('1').id).to eq(1)
    end
  
    it 'should find nil when status with ID does not exist' do
      expect(Radiant::Status.find(0)).to be_nil
    end
  end

  RSpec.describe Status, 'brackets' do
    it 'should allow you to look up with a symbol' do
      expect(Radiant::Status[:draft].name).to eq('Draft')
    end
  
    it 'should return nil if symbol is not associated with a status' do
      expect(Radiant::Status[:whatever]).to eq(nil)
    end
  end

  RSpec.describe Status, 'find_all' do
    it 'should return all statuses as Status objects' do
      statuses = Radiant::Status.find_all
      expect(statuses.size).to be > 0
      statuses.each do |status|
        expect(status).to be_kind_of(Status)
      end
    end
  end

  RSpec.describe Status, 'selectable' do
    it "should return all statuses except 'Scheduled'" do
      statuses = Radiant::Status.selectable
      expect(statuses.size).to be > 0
      statuses.each do |status|
        expect(status).to be_kind_of(Status)
        expect(status.name).not_to eq("Scheduled")
      end
    end
  end
end