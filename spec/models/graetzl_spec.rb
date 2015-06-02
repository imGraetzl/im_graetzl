require 'rails_helper'

RSpec.describe Graetzl, type: :model do

  it 'has a valid factory' do
    expect(build(:graetzl)).to be_valid
  end

  describe 'associations' do
    let(:graetzl) { create(:graetzl) }

    it 'has users' do
      expect(graetzl).to respond_to(:users)
    end

    it 'has meetings' do
      expect(graetzl).to respond_to(:meetings)      
    end

    it 'has posts' do
      expect(graetzl).to respond_to(:posts)      
    end

    describe 'destroy associated records' do
      before do
        3.times { create(:meeting, graetzl: graetzl) }
        3.times { create(:post, graetzl: graetzl) }
      end

      it 'has meetings' do
        expect(graetzl.meetings.count).to eq(3)
      end

      it 'has posts' do
        expect(graetzl.posts.count).to eq(3)
      end

      it 'destroys meetings' do
        meetings = graetzl.meetings
        graetzl.destroy
        meetings.each do |meeting|
          expect(Meeting.find_by_id(meeting.id)).to be_nil
        end
      end

      it 'destroys posts' do
        posts = graetzl.posts
        graetzl.destroy
        posts.each do |post|
          expect(Post.find_by_id(post.id)).to be_nil
        end
      end
    end
  end

  describe '#short_name' do
    let(:aspern) { build(:aspern) }
    it 'returns first part of name' do
      expect(aspern.short_name).to eql('Aspern')
    end
  end
end
