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

    it 'has state (default :open)' do
      expect(graetzl).to respond_to(:state)
      expect(graetzl.open?).to be_truthy
    end
  end

  describe '#districts' do
    let(:graetzl) { create(:graetzl,
      area: 'POLYGON ((1.0 1.0, 1.0 5.0, 5.0 5.0, 5.0 1.0, 1.0 1.0))') }
    let!(:d_intersect) { create(:district,
      area: 'POLYGON ((3.0 3.0, 3.0 6.0, 6.0 6.0, 3.0 3.0))') }
    let!(:d_covers) { create(:district,
      area: 'POLYGON ((0.0 0.0, 0.0 6.0, 6.0 6.0, 6.0 0.0, 0.0 0.0))') }
    let!(:d_outside) { create(:district,
      area: 'POLYGON ((6.0 6.0, 10.0 6.0, 10.0 10.0, 6.0 6.0))') }

    subject(:districts) { graetzl.districts }

    it 'returns intersecting districts' do
      expect(districts.size).to eq 2
    end

    it 'includes intersecting' do
      expect(districts).to include d_intersect
    end

    it 'includes covering' do
      expect(districts).to include d_covers
    end

    it 'excludes outside' do
      expect(districts).not_to include d_outside
    end
  end

  describe '_#activity' do
    let(:graetzl) { create :graetzl }
    subject(:activity) { graetzl.send(:activity) }

    context 'without activity' do
      it 'returns empty collection' do
        expect(activity).to be_empty
      end
    end
    context 'with activity in graetzl' do
      let!(:meeting_1) { create :meeting, graetzl: graetzl }
      let!(:meeting_2) { create :meeting, graetzl: graetzl }
      let!(:user_post) { create :user_post, graetzl: graetzl }
      let!(:location_post) { create :location_post, graetzl: graetzl }

      it 'includes most recent activity per trackable' do
        create_post_1 = user_post.create_activity :create
        create_post_2 = location_post.create_activity :create
        create_meeting_1 = meeting_1.create_activity :create
        create_meeting_2 = meeting_2.create_activity :create
        comment_post_1 = user_post.create_activity :comment
        comment_meeting_1 = meeting_1.create_activity :comment

        expect(activity.ids).to eq [comment_meeting_1, comment_post_1, create_meeting_2, create_post_2].map(&:id)
      end
    end
  end

  describe '#decorate_activity' do
    let(:graetzl) { create :graetzl, area: 'POLYGON ((0.0 0.0, 0.0 5.0, 5.0 5.0, 0.0 0.0))'}
    let!(:district) { create :district, area: 'POLYGON ((0.0 0.0, 0.0 10.0, 10.0 10.0, 10.0 0.0, 0.0 0.0))' }
    let(:activites) { create_list :activity, 10 }
    before do
      allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
    end
    subject(:decorate_activity) { graetzl.decorate_activity activites }

    context 'when no live zuckerl available' do
      it 'returns only activity' do
        expect(decorate_activity).to match_array activites
      end
    end
    context 'when live zuckerl available' do
      let!(:zuckerls) { create_list :zuckerl, 2, :live, location: create(:location, graetzl: graetzl) }

      it 'contains activity' do
        expect(decorate_activity).to include *activites
      end

      it 'contains zuckerls' do
        expect(decorate_activity).to include *zuckerls
      end
    end
  end

  describe '#zuckerls' do
    it "is a pending example"
  end
end
