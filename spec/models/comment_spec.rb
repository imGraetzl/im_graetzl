require 'rails_helper'

RSpec.describe Comment, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed :comment).to be_valid
  end

  describe 'associations' do
    let(:comment) { create :comment }

    it 'has user' do
      expect(comment).to respond_to :user
    end

    it 'has commentables' do
      expect(comment).to respond_to :commentable
    end

    describe 'images' do
      it 'has images' do
        expect(comment).to respond_to :images
      end

      it 'destroys images' do
        create_list :image, 3, imageable: comment
        expect{
          comment.destroy
        }.to change{Image.count}.from(3).to 0
      end
    end
  end

  describe 'validations' do
    it 'is invalid without content' do
      expect(build :comment, content: '').not_to be_valid
    end
  end

  describe 'callbacks' do
    let(:comment) { create :comment }

    describe 'before_destroy' do
      it 'destroys associated activity' do
        create_list :activity, 3, recipient: comment, key: 'user.comment'
        expect{
          comment.destroy
        }.to change{Activity.count}.by -3
      end
    end
  end

  describe '#edit_permission?' do
    let(:user) { create :user }
    context 'when comment by user' do
      let(:comment) { create :comment, user: user }

      it 'returs true for user' do
        expect(comment.edit_permission?(user)).to be_truthy
      end

      it 'returs true for admin' do
        expect(comment.edit_permission?(create(:user, :admin))).to be_truthy
      end

      it 'returns false for other user' do
        expect(comment.edit_permission?(create(:user))).to be_falsey
      end

      it 'returns false for nil' do
        expect(comment.edit_permission? nil).to be_falsey
      end
    end

    context 'when user commentable' do
      let(:other_user) { create :user }
      let(:comment) { create(:comment, commentable: user, user: other_user) }

      it 'returs true for commentable user' do
        expect(comment.edit_permission?(user)).to be_truthy
      end

      it 'returs true for comment user' do
        expect(comment.edit_permission?(other_user)).to be_truthy
      end

      it 'returs true for admin' do
        expect(comment.edit_permission?(create(:user, :admin))).to be_truthy
      end

      it 'returns false for random user' do
        expect(comment.edit_permission?(create(:user))).to be_falsey
      end
    end
  end
end
