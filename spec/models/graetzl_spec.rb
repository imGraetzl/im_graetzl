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

    it 'has initiatives' do
      expect(graetzl).to respond_to :initiatives
      expect(graetzl).to respond_to :operating_ranges
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

    describe 'posts' do
      it 'has posts' do
        expect(graetzl).to respond_to :posts
      end

      it 'destroys posts' do
        create_list :user_post, 3, graetzl: graetzl
        create_list :location_post, 3, graetzl: graetzl
        expect{
          graetzl.destroy
        }.to change(Post, :count).by -6
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

    describe 'curator' do
      it 'has curator' do
        expect(graetzl).to respond_to :curator
      end

      it 'destroys curator' do
        create :curator, graetzl: graetzl
        expect{
          graetzl.destroy
        }.to change(Curator, :count).by(-1)
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

  describe '#build_meeting' do
    let(:graetzl) { create :graetzl }
    subject(:meeting) { graetzl.build_meeting }

    it 'returns new meeting in graetzl' do
      expect(meeting).to be_a Meeting
      expect(meeting).to have_attributes(graetzl: graetzl)
    end

    it 'adds address' do
      expect(meeting.address).not_to be_nil
    end
  end
end
