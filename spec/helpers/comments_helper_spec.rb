require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do

  describe '#comment_outer_wrapper' do
    let(:comment) { build_stubbed :comment }

    it 'retuns empty class for inline' do
      comment.inline = true
      expect(helper.comment_outer_wrapper comment).to eq ''
    end

    it 'retuns streamElement class for stream comment' do
      expect(helper.comment_outer_wrapper comment).to eq 'streamElement'
    end
  end

  describe '#comment_wrapper' do
    let(:comment) { build_stubbed :comment }

    it 'retuns empty entryUserComment class for inline' do
      comment.inline = true
      expect(helper.comment_wrapper comment).to eq 'entryUserComment'
    end

    it 'retuns entryInitialContent class for stream comment' do
      expect(helper.comment_wrapper comment).to eq 'entryInitialContent'
    end
  end

  describe '#link_to_load_comments' do
    context 'when commentable is post' do
      let(:post) { build_stubbed(:post) }
      subject(:link) { helper.link_to_load_comments(post) }

      it 'renders link to post_comments_path' do
        expect(link).to include("href=\"#{post_comments_path post}\"")
      end

      it 'has rel=nofollow attribute' do
        expect(link).to include("rel=\"nofollow\"")
      end
    end
  end
end
