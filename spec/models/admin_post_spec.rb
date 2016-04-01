require 'rails_helper'
require 'models/shared/post'
require 'models/shared/trackable'

RSpec.describe AdminPost, type: :model do
  it_behaves_like :a_post
  it_behaves_like :a_trackable

  it 'has a valid factory' do
    expect(build_stubbed :admin_post).to be_valid
  end

  describe 'own associations' do
    let(:admin_post) { create :admin_post }

    it 'does not have graetzl' do
      expect(admin_post).not_to respond_to :graetzl
    end

    it 'has graetzls' do
      expect(admin_post).to respond_to :graetzls
    end

    it 'has graetzls' do
      expect(admin_post).to respond_to :operating_ranges
    end
  end

  describe '#edit_permission?' do
    let(:post) { create :admin_post }

    it 'returns true if user admin' do
      admin = create :user, :admin
      expect(post.edit_permission? admin).to eq true
    end

    it 'returns false for any other user' do
      other_user = create :user
      expect(post.edit_permission? other_user).to eq false
    end
  end
end
