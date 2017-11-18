require 'rails_helper'

RSpec.describe ActivityStream, type: :model do

  describe '#fetch' do
    let!(:user) { create :user }
    let(:graetzl) { create :graetzl }
    subject(:activity_stream) { ActivityStream.new(graetzl).fetch }

    context 'without activity' do
      it 'returns empty collection' do
        expect(activity_stream).to be_empty
      end
    end
    context 'with activity in graetzl' do
      let!(:meeting_1) { create :meeting, graetzl: graetzl }
      let!(:meeting_2) { create :meeting, graetzl: graetzl }
      let!(:user_post) { create :user_post, graetzl: graetzl }
      let!(:location_post) { create :location_post, graetzl: graetzl }
      let!(:admin_post) { create :admin_post }

      before { create :operating_range, operator: admin_post, graetzl: graetzl }

      it 'includes most recent activity per trackable' do
        create_admin_post = admin_post.create_activity :create
        create_post_1 = user_post.create_activity :create
        create_post_2 = location_post.create_activity :create
        create_meeting_1 = meeting_1.create_activity :create
        create_meeting_2 = meeting_2.create_activity :create
        comment_post_1 = user_post.create_activity :comment
        comment_meeting_1 = meeting_1.create_activity :comment

        expect(activity_stream).to eq [comment_meeting_1, comment_post_1, create_meeting_2, create_post_2, create_admin_post]
      end
    end
  end

  describe '#insert_zuckerls' do
    let(:graetzl) { create :graetzl }
    let!(:district) { create :district, graetzls: [graetzl] }
    let(:activities) { create_list :activity, 10 }
    before do
      allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
    end
    subject(:insert_zuckerls) { ActivityStream.new(graetzl).insert_zuckerls(activities) }

    context 'when no live zuckerl available' do
      it 'returns only activity' do
        expect(insert_zuckerls).to match_array activities
      end
    end
    context 'when live zuckerl available' do
      let!(:zuckerls) { create_list :zuckerl, 2, :live, location: create(:location, graetzl: graetzl) }

      it 'contains activity' do
        expect(insert_zuckerls).to include *activities
      end

      it 'contains zuckerls' do
        expect(insert_zuckerls).to include *zuckerls
      end
    end
  end

end
