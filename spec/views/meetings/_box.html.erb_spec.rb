require 'rails_helper'

RSpec.describe 'meetings/_box', type: :view do
  context 'without location' do
    let(:meeting) { create(:meeting, location: nil) }
    before { render 'meetings/box', meeting: meeting }

    it 'displays graetzl flag' do
      expect(rendered).to have_selector('div.sideflag', text: meeting.graetzl.name)
    end
  end

  context 'with location' do
    let(:meeting) { create(:meeting, location: create(:location)) }

    context 'when not owned by initiator' do
      before do
        allow(meeting).to receive(:initiator) { create(:user) }
        allow(meeting.location).to receive(:users) { [create(:user)] }
        render 'meetings/box', meeting: meeting
      end

      it 'displays graetzl flag' do
        expect(rendered).to have_selector('div.sideflag', text: meeting.graetzl.name)
      end
    end

    context 'when owned by initiator' do
      let(:user) { create(:user) }
      before do
        allow(meeting).to receive(:initiator) { user }
        allow(meeting.location).to receive(:users) { [user] }
        render 'meetings/box', meeting: meeting
      end

      it 'does not display graetzl flag' do
        expect(rendered).not_to have_selector('div.sideflag')
      end

      it 'displays location badge' do
        expect(rendered).to have_selector('div.medalBadge')
      end
    end
  end
end