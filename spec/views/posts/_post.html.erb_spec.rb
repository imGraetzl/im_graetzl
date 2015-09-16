require 'rails_helper'

RSpec.describe 'posts/_post', type: :view do
  let(:user) { create(:user) }
  let(:post) { build_stubbed(:post) }
  
  before do
    allow(view).to receive(:current_user) { user }
  end

  describe 'edit controls' do
    context 'when post by user' do
      before do
        allow(post).to receive(:user) { user }
        render 'posts/post', post: post
      end

      it 'displays edit controls' do
        expect(rendered).to have_selector('div.editControls')
      end

      it 'does not display edit button' do
        expect(rendered).not_to have_selector('div.editControls div.btn-edit')
      end

      it 'displays delete button' do
        expect(rendered).to have_selector('div.editControls div.btn-delete')
      end
    end

    context 'when post not by user' do
      before { render 'posts/post', post: post }

      it 'does display edit controls' do
        expect(rendered).not_to have_selector('div.editControls')
      end
    end

    context 'when user admin' do
      before do
        user.admin!
        render 'posts/post', post: post
      end

      it 'displays edit controls' do
        expect(rendered).to have_selector('div.editControls')
      end

      it 'does not display edit button' do
        expect(rendered).not_to have_selector('div.editControls div.btn-edit')
      end

      it 'displays delete button' do
        expect(rendered).to have_selector('div.editControls div.btn-delete')
      end
    end
  end
end