require 'rails_helper'
include GeojsonSupport

RSpec.describe MeetingsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }
  let(:meeting) { create(:meeting, graetzl: graetzl) }

  describe 'GET show' do
    context 'when no current_user' do
      before { get :show, graetzl_id: graetzl.id, id: meeting.id }

      it 'returns a 200 OK status' do
        expect(response).to be_success
        expect(response).to have_http_status(:ok)
      end

      it 'renders #show' do
        expect(response).to render_template(:show)
      end
    end

    context 'when current_user' do
      before do
        sign_in user
        get :show, graetzl_id: graetzl.id, id: meeting.id
      end
      
      it 'returns a 200 OK status' do
        expect(response).to be_success
        expect(response).to have_http_status(:ok)
      end

      it 'renders #show' do
        expect(response).to render_template(:show)
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq(graetzl)
      end

      it 'assigns @meeting' do
        expect(assigns(:meeting)).to eq(meeting)
      end
    end
  end

  describe 'GET index' do
    before do
      3.times { new_meeting = create(:meeting, graetzl: graetzl) }
      past_meeting = build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday)
      past_meeting.save(validate: false)
    end

    context 'when no current_user' do
      before { get :index, graetzl_id: graetzl.id }

      it 'returns a 200 OK status' do
        expect(response).to be_success
        expect(response).to have_http_status(:ok)
      end

      it 'renders #index' do
        expect(response).to render_template(:index)
      end
    end

    context 'when current_user' do
      before do
        sign_in user
        get :index, graetzl_id: graetzl.id
      end
      
      it 'returns a 200 OK status' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders #index' do
        expect(response).to render_template(:index)
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq(graetzl)
      end

      it 'assigns @meetings to @graetzl.meetings' do
        expect(assigns(:meetings)).to eq(graetzl.meetings)
      end

      it 'has 4 meetings' do
        expect(assigns(:meetings).count).to eq(4)        
      end
    end
  end

  describe 'GET new' do
    context 'when no current_user' do
      it 'redirects to login' do
        get :new, graetzl_id: graetzl.id
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user' do
      before do
        sign_in user
        get :new, graetzl_id: graetzl.id
      end

      it 'renders #new' do        
        expect(response).to render_template(:new)
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq(graetzl)
      end

      it 'assigns @meeting and address' do
        expect(assigns(:meeting)).to be_a_new(Meeting)
        expect(assigns(:meeting).address).to be_a_new(Address)
      end
    end
  end

  describe 'POST create' do
    context 'when no current_user' do
      it 'redirects to login' do
        post :create, graetzl_id: graetzl.id
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user' do
      subject(:new_meeting) { Meeting.last }
      let(:params) { {
        graetzl_id: graetzl.id,
        meeting: attributes_for(:meeting).merge({ address_attributes: { description: '' } }),
        feature: '',
        address: ''}
      }

      before { sign_in user }

      it 'creates new meeting' do
        expect {
          post :create, params
        }.to change(Meeting, :count).by(1)
      end

      it 'redirects_to meeting in @graetzl' do
        post :create, params
        expect(response).to redirect_to([graetzl, new_meeting])
      end

      it 'sets current_user as initiator' do
        post :create, params
        expect(new_meeting.going_tos.last).to have_attributes(user: user, role: GoingTo::ROLES[:initiator])
      end

      it 'associates @graetzl with meeting' do
        post :create, params
        expect(new_meeting.graetzl).to eq(graetzl)
      end

      it 'adds address to meeting' do
        post :create, params
        expect(new_meeting.address).to be_present
      end

      it 'adds address description' do
        params[:meeting][:address_attributes][:description] = 'new_address_description'
        post :create, params
        expect(new_meeting.address.description).to eq('new_address_description')
      end

      context 'with category_ids' do
        before do
          5.times { create(:category) }
          params[:meeting][:category_ids] = Category.all.map(&:id)
        end

        it 'adds categories to meeting' do
          post :create, params
          expect(new_meeting.categories.size).to eq(5)
        end
      end

      context 'with feature' do
        let!(:naschmarkt) { create(:naschmarkt) }
        before do
          params[:meeting][:address_attributes][:description] = 'new_address_description'
          params[:feature] = esterhazygasse_hash.to_json
          params[:address] = 'Esterházygasse 5'
          post :create, params
        end

        it 'adds address from feature to meeting' do
          expect(new_meeting.address.street_name).to eq('Esterházygasse')
        end

        it 'adds address_description to meeting' do
          expect(new_meeting.address.description).to eq('new_address_description')
        end

        it 'associates address.graetzl with @meeting' do
          expect(new_meeting.graetzl).to eq(naschmarkt)
        end

        it 'redirects_to meeting in address.graetzl' do
          expect(response).to redirect_to([naschmarkt, new_meeting])
        end
      end

      context 'with only address_description' do
        before do
          params[:meeting][:address_attributes][:description] = 'new_address_description'
          post :create, params
        end

        it 'adds address description to meeting' do
          expect(new_meeting.address.description).to eq('new_address_description')
        end
      end
    end
  end

  describe 'GET edit' do
    context 'when no current_user' do
      it 'redirects to login' do
        get :edit, graetzl_id: graetzl.id, id: meeting.id
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user set' do
      before { sign_in user }

      context 'when not initiator' do
        it 'redirects to meeting_page' do
          get :edit, graetzl_id: graetzl.id, id: meeting.id
          expect(response).to redirect_to([graetzl, meeting])
        end
      end

      context 'when initator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator]) }

        before do
          get :edit, graetzl_id: graetzl.id, id: meeting.id
        end

        it 'assigns requested @meeting' do
          expect(assigns(:meeting)).to eq(meeting)
        end

        it 'assigns requested @graetzl' do
          expect(assigns(:graetzl)).to eq(graetzl)
        end

        it 'renders #edit' do        
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe 'PUT update' do
    let(:params) { {
      graetzl_id: graetzl.id,
      id: meeting.id,
      meeting: attributes_for(:meeting).merge({ address_attributes: { description: '' } }),
      feature: '',
      address: ''
      }}

    context 'when no current_user' do
      it 'redirects to login' do
        put :update, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user set' do
      before { sign_in user }

      context 'when not inititor' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee]) }   

        it 'redirects to meeting' do
          put :update, params
          expect(response).to redirect_to([graetzl, meeting])
        end
      end

      context 'when initiator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator]) }

        it 'assigns requested @meeting' do
          put :update, params
          expect(assigns(:meeting)).to eq(meeting)
        end

        it 'assigns requested @graetzl' do
          put :update, params
          expect(assigns(:graetzl)).to eq(graetzl)
        end

        context 'with valid attributes' do

          before do
            params[:meeting][:name] = 'New name'
            params[:meeting][:description] = 'New description'
            params[:meeting]['starts_at_date'] = '2020-01-01'
            params[:meeting]['starts_at_time'] = '18:00'
            params[:meeting]['ends_at_time'] = '20:00'        
          end

          it 'updates name and description' do
            put :update, params
            meeting.reload
            expect(meeting.name).to eq('New name')
            expect(meeting.description).to eq('New description')
          end

          it 'updates starts_at_date, starts_at_time, ends_at_time' do
            put :update, params
            meeting.reload
            expect(meeting.starts_at_date.strftime('%Y-%m-%d')).to eq ('2020-01-01')
            expect(meeting.ends_at_date).to be_falsy
            expect(meeting.starts_at_time.strftime('%H:%M')).to eq ('18:00')
            expect(meeting.ends_at_time.strftime('%H:%M')).to eq ('20:00')
          end

          context 'with categories' do

            before do
              5.times { create(:category) }
              params[:meeting][:category_ids] = Category.all.map(&:id)
            end

            it 'updates categories' do
              put :update, params
              meeting.reload
              expect(meeting.categories.size).to eq(5)
            end
          end

          context 'with address_attributes' do
            let!(:naschmarkt) { create(:naschmarkt) }
            before do
              params[:meeting][:address_attributes][:description] = 'New address_description'
              params[:feature] = esterhazygasse_hash.to_json              
              params[:address] = 'Esterházygasse 5'

              put :update, params
              meeting.reload
            end

            it 'updates address_description' do
              expect(meeting.address.description).to eq('New address_description')
            end

            it 'updates address attributes' do
              expect(meeting.address.street_name).to eq('Esterházygasse')
            end

            it 'updates graetzl_id' do
              expect(meeting.graetzl).to eq(naschmarkt)
            end

            it 'redirects_to meeting in new graetzl' do
              expect(response).to redirect_to([naschmarkt, meeting])
            end
          end

          context 'when remove address' do
            let(:address) { create(:address) }
            before do
              params[:address] = ''
              params[:feature] = ''
              meeting.address = address
            end

            it 'had address' do
              expect(meeting.address.street_name).to eq(address.street_name)
            end

            it 'removes address' do
              put :update, params
              meeting.reload
              expect(meeting.address.street_name).to be_falsy
            end

            it 'keeps address_description' do
              put :update, params
              meeting.reload
              expect(meeting.address.description).to be
            end
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator]) }

    context 'when current_user set' do
      before { sign_in user }

      it 'deletes record' do
        expect {
          delete :destroy, graetzl_id: graetzl, id: meeting
        }.to change(Meeting, :count).by(-1)
      end

      it 'deletes going_tos' do
        expect {
          delete :destroy, graetzl_id: graetzl, id: meeting
        }.to change(GoingTo, :count).by(-1)
      end

      it 'redirects to graetzl_path' do
        delete :destroy, graetzl_id: graetzl, id: meeting
        expect(response).to redirect_to(graetzl)
      end
    end
  end
end
