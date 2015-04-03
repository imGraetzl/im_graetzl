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
      it 'renders fetch_graetzl template' do
        xhr :post, :fetch_graetzl, address: 'mariahilferstraße 10'
        expect(response).to render_template(:fetch_graetzl)
      end
    end

    context 'with esterhazygasse address parameter' do
      let(:esterhazygasse) { build(:esterhazygasse) }

      before do
        @naschmarkt = create(:naschmarkt)
        2.times { create(:graetzl) }
      end

      it 'assigns correct address object' do
        xhr :post, :fetch_graetzl, address: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
        expect(assigns(:address).attributes).to eql(esterhazygasse.attributes)
      end
      it 'assigns correct graetzl object' do
        xhr :post, :fetch_graetzl, address: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
        expect(assigns(:graetzls).first.name).to eql(@naschmarkt.name)
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
      it 'renders no_address template' do
        xhr :post, :fetch_graetzl
        expect(response).to render_template('no_address')
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
      it 'renders no_address template' do
        xhr :post, :fetch_graetzl
        expect(response).to render_template(:no_address)
      end
    end
  end

end
