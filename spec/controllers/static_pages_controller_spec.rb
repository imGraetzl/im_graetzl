require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do

  describe 'GET home' do
    context 'when logged out' do
      before { get :home }

      it 'renders #home' do
        expect(response).to render_template(:home)
      end

      it 'assigns @meetings' do
        expect(assigns(:meetings)).to be
      end

      describe '@meetings' do
        subject(:meetings) { assigns(:meetings) }

        context 'without meetings' do
          it 'is empty' do
            get :home
            expect(meetings).to be_empty
          end
        end

        context 'with meetings' do
          let(:past_meeting) { build(:meeting, starts_at_date: Date.yesterday) }
          let!(:upcoming_meeting) { create(:meeting, starts_at_date: Date.tomorrow) }
          let!(:nil_meeting) { create(:meeting, starts_at_date: nil) }
          
          before do
            past_meeting.save(validate: false)
            get :home
          end

          it 'contains 2 upcoming meetings' do
            expect(meetings).to contain_exactly(upcoming_meeting, nil_meeting)
          end

          it 'excludes past meetings' do
            expect(meetings).not_to include(past_meeting)
          end
        end
      end
    end
  end
end