require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  it 'has a valid factory' do
    expect(build_stubbed(:post)).to be_valid
  end

  describe 'associations' do
    let(:post) { build_stubbed(:post) }

    it 'has content' do
      expect(post).to respond_to(:content)
    end

    it 'has user' do
      expect(post).to respond_to(:user)      
    end

    it 'has graetzl' do
      expect(post).to respond_to(:graetzl)      
    end
  end

  describe 'default scope' do
    let!(:older_post) { create(:post, created_at: 1.day.ago) }
    let!(:newer_post) { create(:post, created_at: 1.hour.ago) }

    it 'has newer_post before older_post' do
      expect(Post.all).to eq([newer_post, older_post])
    end
  end
end
