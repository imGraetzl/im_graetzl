require 'rails_helper'

RSpec.describe Admin::PostsController, type: :controller do
  # let(:admin) { create(:user, role: User.roles[:admin]) }
  #
  # before { sign_in admin }
  #
  # describe 'GET index' do
  #   before { get :index }
  #
  #   it 'returns success' do
  #     expect(response).to have_http_status(200)
  #   end
  #
  #   it 'assigns @posts' do
  #     expect(assigns(:posts)).not_to be_nil
  #   end
  #
  #   it 'renders :index' do
  #     expect(response).to render_template(:index)
  #   end
  # end
  #
  # describe 'GET show' do
  #   let(:post) { create(:post) }
  #   before { get :show, id: post }
  #
  #   it 'returns success' do
  #     expect(response).to have_http_status(200)
  #   end
  #
  #   it 'assigns @post' do
  #     expect(assigns(:post)).to eq post
  #   end
  #
  #   it 'renders :show' do
  #     expect(response).to render_template(:show)
  #   end
  # end
  #
  # describe 'GET new' do
  #   it 'is not routable' do
  #     expect(get: '/admin/posts/new').not_to route_to('admin/posts#new')
  #   end
  # end
  #
  # describe 'POST create' do
  #   it 'is not routable' do
  #     expect(post: '/admin/posts').not_to be_routable
  #   end
  # end
  #
  # describe 'GET edit' do
  #   let(:post) { create(:post) }
  #   before { get :edit, id: post }
  #
  #   it 'returns success' do
  #     expect(response).to have_http_status(200)
  #   end
  #
  #   it 'assigns @post' do
  #     expect(assigns(:post)).to eq post
  #   end
  #
  #   it 'renders :edit' do
  #     expect(response).to render_template(:edit)
  #   end
  # end
  #
  # describe 'PATCH update' do
  #   let(:post) { create(:post) }
  #   let(:other_post) { build(:post) }
  #   let(:params) {
  #     { id: post, post: {
  #       author_id: other_post.author_id,
  #       author_type: other_post.author_type,
  #       title: other_post.title,
  #       content: other_post.content }
  #     }
  #   }
  #
  #   context 'basic attributes' do
  #     before do
  #       patch :update, params
  #       post.reload
  #     end
  #
  #     it 'updates attributes' do
  #       expect(post).to have_attributes(
  #         author: other_post.author,
  #         title: other_post.title,
  #         content: other_post.content)
  #     end
  #
  #     it 'redirects to post page' do
  #       expect(response).to redirect_to(admin_post_path(post))
  #     end
  #   end
  #
  #   context 'update image' do
  #     let!(:image) { create(:image, imageable: post) }
  #     before do
  #       params[:post].merge!(images_attributes: {'0' => { id: image.id, file_id: Faker::Internet.password(20) }})
  #     end
  #
  #     it 'updates image' do
  #       expect{
  #         patch :update, params
  #         post.reload
  #       }.to change(image, :file)
  #     end
  #   end
  # end
  #
  # describe 'DELETE destroy' do
  #   let!(:post) { create(:post) }
  #
  #   it 'deletes post record' do
  #     expect{
  #       delete :destroy, id: post
  #     }.to change{Post.count}.by(-1)
  #   end
  #
  #   it 'redirects_to index page' do
  #     delete :destroy, id: post
  #     expect(response).to redirect_to(admin_posts_path)
  #   end
  # end
end
