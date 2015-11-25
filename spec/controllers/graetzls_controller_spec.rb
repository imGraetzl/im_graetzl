require 'rails_helper'

RSpec.describe GraetzlsController, type: :controller do
  render_views false
  let(:user) { create(:user) }
  let(:graetzl) { create(:graetzl) }

  describe 'GET show' do
    context 'when html request' do
      before { get :show, id: graetzl }

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns @activities' do
        expect(assigns(:activities)).to be
      end

      it 'assigns @map_data' do
        expect(assigns(:map_data)).to be_present
      end

      it 'renders show.html' do
        expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
        expect(response).to render_template(:show)
      end
    end

      # describe '@meetings' do
      #   context 'with upcoming meetings' do
      #     before do
      #       3.times{ create(:meeting, graetzl: graetzl, starts_at_date: Date.tomorrow) }
      #       get :show, id: graetzl
      #     end

      #     it 'assigns 2 upcoming meetings' do
      #       expect(assigns(:meetings).count).to eq 2
      #     end
      #   end
      #   context 'without upcoming meetings' do
      #     before do
      #       3.times do
      #         meeting = build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday)
      #         meeting.save(validate: false)
      #       end
      #       get :show, id: graetzl
      #     end

      #     it 'returns empty collection' do
      #       expect(assigns(:meetings)).to be_empty
      #     end
      #   end
      # end

      # describe '@locations' do
      #   context 'with approved locations' do
      #     before do
      #       3.times{ create(:location, graetzl: graetzl, state: Location.states[:approved]) }
      #       get :show, id: graetzl
      #     end

      #     it 'assigns 2 locations' do
      #       expect(assigns(:locations).count).to eq 2
      #     end
      #   end
      #   context 'without approved locations' do
      #     before do
      #       3.times{ create(:location, graetzl: graetzl) }
      #       get :show, id: graetzl
      #     end

      #     it 'is empty' do
      #       expect(assigns(:locations)).to be_empty
      #     end
      #   end
      # end

    context 'when js request' do
      before { xhr :get, :show, id: graetzl }

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns @activities' do
        expect(assigns(:activities)).to be
      end

      it 'does not assign @map_data' do
        expect(assigns(:map_data)).not_to be
      end

      it 'renders show.js' do
        expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
        expect(response).to render_template(:show)
      end
    end
  end
end
