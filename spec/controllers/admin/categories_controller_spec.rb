require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @categories' do
      expect(assigns(:categories)).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    let!(:category) { create(:category) }
    before { get :show, id: category }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @category' do
      expect(assigns(:category)).to eq category
    end

    it 'renders :show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @category' do
      expect(assigns(:category)).to be_a_new(Category)
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:category) { build(:category) }
    let(:params) {
      {
        category: {
          name: category.name,
          context: category.context
        }
      }
    }

    it 'creates new category record' do
      expect{
        post :create, params
      }.to change{Category.count}.by(1)
    end

    it 'assigns attributes to graetzl' do
      post :create, params
      c = Category.last
      expect(c).to have_attributes(
        name: category.name,
        context: category.context)
    end

    it 'redirects_to new category page' do
      post :create, params
      new_category = Category.last
      expect(response).to redirect_to(admin_category_path(new_category))
    end
  end

  describe 'GET edit' do
    let(:category) { create(:category) }
    before { get :edit, id: category }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @category' do
      expect(assigns(:category)).to eq category
    end

    it 'renders :edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    let(:category) { create(:category) }
    let(:new_category) { build(:category, context: Category.contexts[:business]) }
    let(:params) {
      {
        id: category,
        category: {
          name: new_category.name,
          context: new_category.context
        }
      }
    }

    before do
      patch :update, params
      category.reload
    end

    it 'redirects to category page' do
      expect(response).to redirect_to(admin_category_path(category))
    end

    it 'updates category attributes' do
      expect(category).to have_attributes(
        name: new_category.name,
        context: new_category.context)
    end
  end

  describe 'DELETE destroy' do
    let!(:category) { create(:category) }

    it 'deletes category record' do
      expect{
        delete :destroy, id: category
      }.to change{Category.count}.by(-1)
    end

    it 'redirects_to index page' do
      delete :destroy, id: category
      expect(response).to redirect_to(admin_categories_path)
    end
  end
end
