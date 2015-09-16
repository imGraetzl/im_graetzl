require 'rails_helper'

RSpec.describe Post, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:post)).to be_valid
  end

  describe 'attributes' do
    let(:post) { create(:post) }

    it 'has friendly_id' do
      expect(post).to respond_to(:slug)
    end
  end

  describe 'associations' do
    let(:post) { create(:post) }

    it 'has user' do
      expect(post).to respond_to(:user)      
    end

    it 'has graetzl' do
      expect(post).to respond_to(:graetzl)      
    end

    it 'has comments' do
      expect(post).to respond_to(:comments)      
    end

    it 'has images' do
      expect(post).to respond_to(:images)      
    end

    describe 'destroy associated records' do
      before do
        3.times { create(:comment, commentable: post) }
        3.times { create(:image, imageable: post) }
      end

      it 'has comments' do
        expect(post.comments.count).to eq(3)
      end

      it 'destroys comments' do
        comments = post.comments
        post.destroy
        comments.each do |comment|
          expect(Comment.find_by_id(comment.id)).to be_nil
        end
      end

      it 'has images' do
        expect(post.images.count).to eq(3)
      end

      it 'destroys images' do
        images = post.images
        post.destroy
        images.each do |image|
          expect(Image.find_by_id(image.id)).to be_nil
        end
      end
    end
  end

  describe 'scopes' do
    describe 'default scope' do
      let!(:older_post) { create(:post, created_at: 1.day.ago) }
      let!(:newer_post) { create(:post, created_at: 1.hour.ago) }

      it 'retrieves newer_post before older_post' do
        expect(Post.all).to eq([newer_post, older_post])
      end
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

  describe '#date_and_snippet' do
    context 'when new object' do
      let(:month) { Time.now.strftime('%m') }
      let(:year) { Time.now.strftime('%Y') }
      let(:post) { build(:post) }

      it 'includes current month, year and ...' do
        expect(post.date_and_snippet).to include(month, year, '...')
      end

      it 'includes 20 chars of content' do
        expect(post.date_and_snippet).to include(post.content[0..20])
      end
    end
    context 'when new object' do
      let(:created_at_time) { Time.now-2.months }
      let(:month) { created_at_time.strftime('%m') }
      let(:year) { created_at_time.strftime('%Y') }
      let(:post) { build(:post) }

      before do
        post.created_at = created_at_time
        post.save(validate: false)
      end

      it 'includes current month, year and ...' do
        expect(post.date_and_snippet).to include(month, year, '...')
      end

      it 'includes 20 chars of content' do
        expect(post.date_and_snippet).to include(post.content[0..20])
      end
    end
  end

  describe 'callbacks' do
    let(:post) { create(:post) }

    describe 'before_destroy' do
      before do
        3.times do
          activity = create(:activity, trackable: post, key: 'post.something')
          3.times{ create(:notification, activity: activity) }
        end
      end

      it 'destroys associated activity and notifications' do
        expect(PublicActivity::Activity.count).to eq 3
        expect(Notification.count).to eq 9

        post.destroy

        expect(Notification.count).to eq 0
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end
end