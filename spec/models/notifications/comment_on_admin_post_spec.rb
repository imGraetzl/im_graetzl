require 'rails_helper'

RSpec.describe Notifications::CommentOnAdminPost, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'admin_post.comment' }
    let(:other_activity) { build :activity, key: 'admin_post.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentOnAdminPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentOnAdminPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let(:user) { create :user }
    let(:admin_post) { create :admin_post, author: user }
    let(:activity) { create :activity, trackable: admin_post }

    subject(:receivers) { Notifications::CommentOnAdminPost.receivers(activity) }

    it 'returns post author' do
      expect(receivers).to eq [user]
    end
  end

  describe '.condition(activity)' do
    let(:user) { create :user }
    let(:admin_post) { create :admin_post, author: user }
    let(:activity) { create :activity, trackable: admin_post }

    subject(:condition) { Notifications::CommentOnAdminPost.condition activity }

    it 'returns false if author activity owner' do
      allow(activity).to receive(:owner_id) { user.id }
      expect(condition).to eq false
    end

    it 'returns true if author not activity owner' do
      expect(condition).to eq true
    end
  end

  describe '#basic_mail_vars' do
    let(:graetzl) { create :graetzl, name: 'this_graetzl' }
    let(:user) { create :user, graetzl: graetzl }
    let(:notification) { Notifications::CommentOnAdminPost.new(user: user, activity: create(:activity, trackable: create(:admin_post))) }

    subject(:mail_vars) { notification.basic_mail_vars }

    it 'returns user graetzl' do
      expect(mail_vars).to include({ name: 'graetzl_name', content: 'this_graetzl' })
    end
  end
end
