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
        create_list :post, 3, graetzl: graetzl
        expect{
          graetzl.destroy
        }.to change(Post, :count).by -3
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
      let!(:post_1) { create :post, graetzl: graetzl }
      let!(:post_2) { create :post, graetzl: graetzl }

      it 'includes most recent activity per trackable' do
        create_post_1 = post_1.create_activity :create
        create_post_2 = post_2.create_activity :create
        create_meeting_1 = meeting_1.create_activity :create
        create_meeting_2 = meeting_2.create_activity :create
        comment_post_1 = post_1.create_activity :comment
        comment_meeting_1 = meeting_1.create_activity :comment

        expect(activity.ids).to eq [comment_meeting_1, comment_post_1, create_meeting_2, create_post_2].map(&:id)
      end
    end
  end

  describe '#feed_items' do
    before { allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation) }
    let(:graetzl) { create :graetzl }

    context 'for page 1' do
      let(:posts) { create_list :post, 6, graetzl: graetzl }
      let(:meetings) { create_list :meeting, 6, graetzl: graetzl }
      let!(:zuckerl_1) { create :zuckerl, aasm_state: 'live', location: create(:location, graetzl: graetzl) }
      let!(:zuckerl_2) { create :zuckerl, aasm_state: 'live', location: create(:location, graetzl: graetzl) }

      it 'includes zuckerl and activity' do
        activites = []
        posts.each do |post|
          activites << post.create_activity(:create, graetzl_id: graetzl.id)
        end
        meetings.each do |meeting|
          activites << meeting.create_activity(:create, graetzl_id: graetzl.id)
        end

        zuckerls = []
        zuckerls << zuckerl_1
        zuckerls << zuckerl_2

        items = graetzl.feed_items(1)

        expect(items).to include(*activites)
        expect(items).to include(*zuckerls)
      end
    end
    # context 'for page 2' do
    #   let(:posts) { create_list :post, 12, graetzl: graetzl }
    #   let(:meetings) { create_list :meeting, 12, graetzl: graetzl }
    #   let!(:zuckerl_1) { create :zuckerl, aasm_state: 'live', location: create(:location, graetzl: graetzl) }
    #   let!(:zuckerl_2) { create :zuckerl, aasm_state: 'live', location: create(:location, graetzl: graetzl) }
    #
    #   it 'includes only activity' do
    #     activites = []
    #     posts.each do |post|
    #       activites << post.create_activity(:create, graetzl_id: graetzl.id)
    #     end
    #     meetings.each do |meeting|
    #       activites << meeting.create_activity(:create, graetzl_id: graetzl.id)
    #     end
    #     zuckerls = []
    #     zuckerls << zuckerl_1
    #     zuckerls << zuckerl_2
    #
    #     items = graetzl.feed_items(2)
    #     puts Activity.first(12).map(&:id)
    #     first_activities = activites.first(12)
    #     # last_activities = activites.first(12).map(&:id)
    #
    #     expect(items).not_to include(*first_activities)
    #     # expect(items).to include(*(activites.last(12)))
    #     expect(items).not_to include(*zuckerls)
    #   end
    # end
  end
end
