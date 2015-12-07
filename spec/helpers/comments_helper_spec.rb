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

  describe '#render_inline_comment' do
    let(:comment) { build_stubbed :comment }

    before { allow(view).to receive(:current_user) { create(:user) }}

    it 'assigns inline to true' do
      expect{
        helper.render_inline_comment comment
      }.to change{comment.inline}.to(true)
    end

    it 'renders comment' do
      expect(helper.render_inline_comment comment).to eq (render comment)
    end
  end
end
