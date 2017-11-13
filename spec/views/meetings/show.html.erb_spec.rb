require 'rails_helper'

RSpec.describe 'meetings/show', type: :view do
  let(:graetzl) { create(:graetzl) }
  let(:meeting) { create(:meeting, graetzl: graetzl) }

  before do
    assign(:meeting, meeting)
    assign(:graetzl, graetzl)
    assign(:comments, meeting.comments.page(params[:page]).per(10))
  end

  context 'when logged out' do
    before { render }

    it 'displays stream' do
      expect(rendered).to have_selector('div.stream')
    end
  end

  context 'when logged in' do
    before do
      sign_in create(:user)
      render
    end

    it 'displays stream' do
      expect(rendered).to have_selector('div.stream')
    end
  end

  context 'when initiator' do
    let(:user) { create(:user) }
    before do
      sign_in user
      create(:going_to, meeting: meeting, user: user, role: GoingTo.roles[:initiator])
    end

    context 'when active meeting' do
      before do
        allow(meeting).to receive(:active?) { true }
        render
      end

      it 'displays button to edit meeting' do
        expect(rendered).to have_button('Treffen bearbeiten')
      end
    end

    context 'when cancelled meeting' do
      before do
        meeting.cancelled!
        render
      end

      it 'does not display button to edit meeting' do
        expect(rendered).not_to have_button('Treffen bearbeiten')
      end

      it 'displays button to reactivate meeting' do
        expect(rendered).to have_button('Treffen reaktivieren')
      end
    end
  end
end
