require 'rails_helper'

RSpec.describe Notifications::NewAdminPost, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'admin_post.create' }
    let(:other_activity) { build :activity, key: 'admin_post.comment' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewAdminPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewAdminPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let(:graetzls) { create_list :graetzl, 3 }
    let(:other_graetzl) { create :graetzl }
    let(:users) { create_list :user, 10, graetzl: graetzls.sample }
    let(:other_user) { create :user, graetzl: other_graetzl }
    let(:admin_post) { create :admin_post }
    let(:activity) { create :activity, trackable: admin_post }

    subject(:receivers) { Notifications::NewAdminPost.receivers activity }

    before do
      graetzls.each{|graetzl| create :operating_range, operator: admin_post, graetzl: graetzl }
    end

    it 'returns users from graetzls' do
      expect(receivers).to match_array users
    end

    it 'does not include users from other graetzl' do
      expect(receivers).not_to include other_user
    end
  end

  describe '#basic_mail_vars' do
    let(:graetzl) { create :graetzl, name: 'this_graetzl' }
    let(:user) { create :user, graetzl: graetzl }
    let(:notification) { Notifications::NewAdminPost.new(user: user, activity: create(:activity, trackable: create(:admin_post))) }

    subject(:mail_vars) { notification.basic_mail_vars }

    it 'returns user graetzl' do
      expect(mail_vars).to include({ name: 'graetzl_name', content: 'this_graetzl' })
    end
  end
end
