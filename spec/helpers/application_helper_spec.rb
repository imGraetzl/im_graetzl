require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::TestHelpers

  describe '#nav_context' do
    context 'when @district' do
      let(:district) { build_stubbed :district }

      it 'returns district' do
        assign(:district, district)
        expect(helper.nav_context).to eq district
      end
    end

    context 'when @graetzl' do
      let(:graetzl) { build_stubbed :graetzl }

      it 'returns graetzl' do
        assign(:graetzl, graetzl)
        expect(helper.nav_context).to eq graetzl
      end
    end

    context 'when @district and @graetzl' do
      let(:district) { build_stubbed :district }

      it 'returns district' do
        assign(:district, district)
        assign(:graetzl, build_stubbed(:graetzl))
        expect(helper.nav_context).to eq district
      end
    end

    context 'when logged in without @district and @graetzl' do
      let(:user) { create :user }
      before { sign_in user }

      it 'returns user.graetzl' do
        expect(helper.nav_context).to eq user.graetzl
      end
    end

    context 'when logged out without @district and @graetzl' do

      it 'returns a guest user' do
        expect(helper.nav_context).to be_a(GuestUser)
      end
    end
  end

  describe '#nav_user' do
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      it 'returns the current user' do
        expect(helper.nav_user).to eq user
      end
    end

    context 'when logged out' do

      it 'returns a guest user' do
        expect(helper.nav_user).to be_a(GuestUser)
      end      
    end
  end
end
