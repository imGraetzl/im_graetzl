require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET show' do
    context 'when logged out' do
      it 'redirects to login_page' do
        get :show, graetzl_id: 'graetzl_slug', id: 'post-slug'
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in create(:user) }

      context 'when author user' do
        let(:post) { create(:post) }

        context 'when html request' do
          before { get :show, graetzl_id: post.graetzl, id: post }

          it 'assigns @post' do
            expect(assigns(:post)).to eq post
          end

          it 'assigns @comments' do
            expect(assigns(:comments)).to be
          end

          it 'renders show.html' do
            expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
            expect(response).to render_template(:show)
          end
        end

        context 'when js request' do
          before { xhr :get, :show, graetzl_id: post.graetzl, id: post }

          it 'assigns @post' do
            expect(assigns(:post)).to eq post
          end

          it 'assigns @comments' do
            expect(assigns(:comments)).to be
          end

          it 'renders show.js' do
            expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
            expect(response).to render_template(:show)
          end
        end
      end

      context 'when author location' do
        let(:post) { create(:post, author: create(:location)) }
        before do
          request.env['HTTP_REFERER'] = 'where_i_came_from'
          get :show, graetzl_id: post.graetzl, id: post
        end

        it 'redirects back to previous page' do
          expect(response).to redirect_to 'where_i_came_from'
        end

        it 'shows flash message' do
          expect(flash[:notice]).to be_present
        end
      end
    end
  end

  # describe 'POST create' do
  #   context 'when logged out' do
  #     it 'redirects to login_page' do
  #       xhr :post, :create
  #       expect(response).to render_template(session[:new])
  #     end
  #   end
  #
  #   context 'when logged in' do
  #     let(:params) { {
  #       post: { graetzl_id: graetzl.id, content: 'post_content' } }
  #     }
  #     before { sign_in user }
  #
  #     it 'creates new post' do
  #       expect {
  #         xhr :post, :create, params
  #       }.to change(Post, :count).by(1)
  #     end
  #
  #     describe 'request', job: true do
  #       before do
  #         PublicActivity.with_tracking do
  #           xhr :post, :create, params
  #         end
  #       end
  #       subject(:new_post) { Post.last }
  #
  #       it 'associates current_user' do
  #         expect(new_post.user).to eq user
  #       end
  #
  #       it 'associates graetzl' do
  #         expect(new_post.graetzl).to eq graetzl
  #       end
  #
  #       it 'assigns @activity' do
  #         expect(assigns(:activity)).not_to be_nil
  #       end
  #
  #       it 'renders activity partial' do
  #         expect(response).to render_template(partial: 'public_activity/post/_create')
  #       end
  #     end
  #   end
  # end
  #
  describe 'DELETE destroy' do
    let(:graetzl) { create(:graetzl) }
    let!(:post) { create(:post, graetzl: graetzl) }

    context 'when logged out' do

      it 'redirects js request to login_page' do
        xhr :delete, :destroy, id: post
        expect(response).to render_template(session[:new])
      end

      it 'redirects html request to login_page' do
        delete :destroy, id: post
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in create(:user) }

      context 'when ajax request' do
        it 'deletes record' do
          expect {
            xhr :delete, :destroy, id: post
          }.to change(Post, :count).by(-1)
        end

        it 'renders destroy.js' do
          xhr :delete, :destroy, id: post
          expect(response['Content-Type']).to include('text/javascript')
          expect(response).to render_template('posts/destroy')
        end
      end

      context 'when html request' do
        it 'deletes post record' do
          expect{
            delete :destroy, id: post
          }.to change{Post.count}.by(-1)
        end

        it 'redirects to graetzl page' do
          delete :destroy, id: post
          expect(response).to redirect_to graetzl
        end
      end
    end
  end
end
