require 'rails_helper'

RSpec.describe 'meetings/show', type: :view do
  let(:graetzl) { create(:graetzl) }

  describe 'stream' do
    before do
      assign(:graetzl, graetzl)
      assign(:meeting, build_stubbed(:meeting, graetzl: graetzl))
      assign(:comments, [])
    end

    context 'when logged out' do
      before { render }

      it 'does not display stream' do
        expect(rendered).not_to have_selector('div.stream')
      end
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before do
        sign_in user
        render
      end

      it 'displays stream' do
        expect(rendered).to have_selector('div.stream')
      end
    end
  end
end