require 'rails_helper'

RSpec.describe 'meetings/edit', type: :view do
  let(:meeting) { create(:meeting) }
  before do
    sign_in create(:user)
    assign(:meeting, meeting)
    allow(meeting).to receive(:initiator) { create(:user) }
  end

  context 'when basic meeting' do
    before { render }

    it 'displays link to cancel meeting' do
      expect(rendered).to have_button('Treffen absagen')
    end
  end
  context 'when cancelled meeting' do
    before do
      meeting.cancelled!
      render
    end

    it 'does not display link to cancel meeting' do
      expect(rendered).not_to have_button('Treffen absagen')
    end
  end
end