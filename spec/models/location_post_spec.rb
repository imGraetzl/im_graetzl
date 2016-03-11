require 'rails_helper'
require 'models/shared/post'
require 'models/shared/trackable'

RSpec.describe LocationPost, type: :model do
  it_behaves_like :a_post
  it_behaves_like :a_trackable

  it 'has a valid factory' do
    expect(build_stubbed :location_post).to be_valid
  end

  describe 'own validations' do
    it 'is invalid without graetzl' do
      expect(build :location_post, graetzl: nil).not_to be_valid
    end
  end

  describe 'own associations' do
    let(:post) { create :location_post }
    it 'has graetzl' do
      expect(post).to respond_to(:graetzl)
    end
  end

  describe '#edit_permission?' do
    let(:user) { create :user }
    let(:location) { create :location, state: Location.states[:approved] }
    let(:post) { create :location_post, author: location }

    before { create :location_ownership, user: user, location: location }

    it 'returns true if user admin' do
      admin = create :admin
      expect(post.edit_permission? admin).to eq true
    end

    it 'returns true if user owns location' do
      expect(post.edit_permission? user).to eq true
    end

    it 'returns false for any other user' do
      other_user = create :user
      expect(post.edit_permission? other_user).to eq false
    end

    it 'returns false if user nil' do
      expect(post.edit_permission? nil).to eq false
    end
  end
end
