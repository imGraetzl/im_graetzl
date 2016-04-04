require 'rails_helper'

RSpec.describe Notifications::AlsoCommentedAdminPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'admin_post.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'admin_post.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::AlsoCommentedAdminPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::AlsoCommentedAdminPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let(:post) { create :admin_post }
    let(:users) { create_list :user, 5 }
    let(:owner) { create :user }
    let(:activity) { create :activity, trackable: post, owner: owner }

    before do
      users.each{|user| create(:comment, user: user, commentable: post) }
      create(:comment, user: owner, commentable: post)
    end

    subject(:receivers) { Notifications::AlsoCommentedAdminPost.receivers activity }

    it 'returns all previous commenters' do
      expect(receivers).to match_array users
    end

    it 'excludes owner of activity' do
      expect(receivers).not_to include owner
    end
  end

  describe '#basic_mail_vars' do
    let(:graetzl) { create :graetzl, name: 'this_graetzl' }
    let(:user) { create :user, graetzl: graetzl }
    let(:notification) { Notifications::AlsoCommentedAdminPost.new(user: user, activity: create(:activity, trackable: create(:admin_post))) }

    subject(:mail_vars) { notification.basic_mail_vars }

    it 'returns user graetzl' do
      expect(mail_vars).to include({ name: 'graetzl_name', content: 'this_graetzl' })
    end
  end
end
