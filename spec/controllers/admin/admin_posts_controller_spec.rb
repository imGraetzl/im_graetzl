require 'rails_helper'

RSpec.describe Admin::AdminPostsController, type: :controller do
  describe 'POST create' do
    let(:admin) { create :user, :admin }
    let(:graetzls) { create_list :graetzl, 3 }
    let(:params) {{ admin_post: { title: 'hello', content: 'world', graetzl_ids: graetzls.map(&:id) }}}

    before { sign_in admin }

    it 'assigns @admin_post' do
      post :create, params
      expect(assigns :admin_post).to have_attributes(
        author: admin,
        title: 'hello', content: 'world', graetzl_ids: graetzls.map(&:id))
    end

    it 'creates admin_post record' do
      expect{
        post :create, params
      }.to change{AdminPost.count}.by 1
    end
  end
end
