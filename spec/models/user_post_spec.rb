require 'rails_helper'
require 'models/shared/post'
require 'models/shared/trackable'

RSpec.describe UserPost, type: :model do
  it_behaves_like :a_post
  it_behaves_like :a_trackable

  it 'has a valid factory' do
    expect(build_stubbed :user_post).to be_valid
  end

  describe 'own validations' do
    it 'is invalid without graetzl' do
      expect(build :user_post, graetzl: nil).not_to be_valid
    end
  end

  describe 'own associations' do
    let(:post) { create :user_post }
    it 'has graetzl' do
      expect(post).to respond_to :graetzl
    end
  end

  describe '#edit_permission?' do
    let(:user) { create :user }
    let(:post) { create :user_post, author: user }

    it 'returns true if user admin' do
      admin = create :user, :admin
      expect(post.edit_permission? admin).to eq true
    end

    it 'returns true if user author' do
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
