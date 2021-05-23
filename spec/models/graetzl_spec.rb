require 'rails_helper'

RSpec.describe Graetzl, type: :model do

  it 'has a valid factory' do
    expect(build(:graetzl)).to be_valid
  end

  describe 'associations' do
    let(:graetzl) { create(:graetzl) }

    it 'has users' do
      expect(graetzl).to respond_to(:users)
    end

    describe 'meetings' do
      it 'has meetings' do
        expect(graetzl).to respond_to(:meetings)
      end

      it 'destroys meetings' do
        create_list :meeting, 3, graetzl: graetzl
        expect{
          graetzl.destroy
        }.to change(Meeting, :count).by -3
      end
    end

    describe 'locations' do
      it 'has locations' do
        expect(graetzl).to respond_to(:locations)
      end

      it 'destroys locations' do
        create_list :location, 3, graetzl: graetzl
        expect{
          graetzl.destroy
        }.to change(Location, :count).by -3
      end
    end
  end

  describe 'macros' do
    let(:graetzl) { create(:graetzl) }

    it 'has friendly_id' do
      expect(graetzl).to respond_to(:slug)
    end
  end

  describe '#zuckerls' do
    it "is a pending example"
  end

end
