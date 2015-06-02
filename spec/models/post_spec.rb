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

  describe 'validations' do

    it 'is invalid without content' do
      expect(build(:post, content: '')).not_to be_valid
    end

    it 'is invalid without user' do
      expect(build(:post, user: nil)).not_to be_valid
    end

    it 'is invalid without graetzl' do
      expect(build(:post, graetzl: nil)).not_to be_valid
    end
  end
end