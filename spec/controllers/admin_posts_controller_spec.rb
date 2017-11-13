require 'rails_helper'

RSpec.describe AdminPostsController, type: :controller do
  describe 'GET show' do
    let(:post) { create :admin_post }
    let!(:old_comments) { create_list :comment, 10, commentable: post }
    let!(:new_comments) { create_list :comment, 10, commentable: post }

    context 'when html request' do
      before { get :show, params: { id: post.id } }

      it 'assigns @post' do
        expect(assigns :post).to eq post
      end

      it 'assigns all @comments' do
        expect(assigns :comments).to match_array(new_comments + old_comments)
      end

      it 'renders show.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:show)
      end
    end
    context 'when no admin_post' do
      let(:post) { create :location_post }

      it 'raises record not found exception' do
        expect{
          get :show, params: { id: post }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
