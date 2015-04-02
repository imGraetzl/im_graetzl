require 'rails_helper'

RSpec.describe AddressesController, type: :controller do

  describe 'POST fetch_graetzl' do

    context 'with address parameter' do
      it 'assigns address' do
        xhr :post, :fetch_graetzl, address: 'mariahilferstraße 10'
        expect(assigns(:address)).not_to be_nil
      end
      it 'assigns graetzls' do
        xhr :post, :fetch_graetzl, address: 'mariahilferstraße 10'
        expect(assigns(:graetzls)).not_to be_nil
      end
    end

    context 'without address parameter' do
      it 'assigns nothing' do
        xhr :post, :fetch_graetzl
        expect(assigns(:address)).to be_nil
        expect(assigns(:graetzls)).to be_nil
      end
      it 'returns flash message' do
        xhr :post, :fetch_graetzl
        expect(flash[:error]).to be_present
      end
    end

    context 'with blank address parameter' do
      it 'assigns nothing' do
        xhr :post, :fetch_graetzl, address: ''
        expect(assigns(:address)).to be_nil
        expect(assigns(:graetzls)).to be_nil
      end
      it 'returns flash message' do
        xhr :post, :fetch_graetzl, address: ''
        expect(flash[:error]).to be_present
      end
    end
  end

end
