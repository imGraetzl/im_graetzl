require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::TestHelpers

  describe 'baumler_add' do
    context 'when :baumler not set in session' do
      context 'when logged out' do
        it 'renders baumler on root' do
          allow(helper).to receive(:current_page?).with(root_url){ true }
          expect(helper).to receive(:render).with('baumler')
          helper.baumler_add
        end

        it 'renders baumler on other page' do
          allow(helper).to receive(:current_page?).with(root_url){ false }
          expect(helper).to receive(:render).with('baumler')
          helper.baumler_add
        end
      end
      context 'when logged in' do
        before { sign_in create(:user) }

        it 'renders baumler on root' do
          allow(helper).to receive(:current_page?).with(root_url){ true }
          expect(helper).to receive(:render).with('baumler')
          helper.baumler_add
        end

        it 'renders baumler on other page' do
          allow(helper).to receive(:current_page?).with(root_url){ false }
          expect(helper).to receive(:render).with('baumler')
          helper.baumler_add
        end
      end
    end
    context 'when :baumler set in session' do
      let(:session) { {baumler: 'seen'} }

      before { allow(helper).to receive(:session){ session } }

      context 'when logged out' do
        it 'renders baumler on root' do
          allow(helper).to receive(:current_page?).with(root_url){ true }
          expect(helper).to receive(:render).with('baumler')
          helper.baumler_add
        end

        it 'does not render baumler on other page' do
          allow(helper).to receive(:current_page?).with(root_url){ false }
          expect(helper).not_to receive(:render).with('baumler')
          helper.baumler_add
        end
      end
      context 'when logged in' do
        before { sign_in create(:user) }

        it 'does not render baumler on root' do
          allow(helper).to receive(:current_page?).with(root_url){ true }
          expect(helper).not_to receive(:render).with('baumler')
          helper.baumler_add
        end

        it 'does not render baumler on other page' do
          allow(helper).to receive(:current_page?).with(root_url){ false }
          expect(helper).not_to receive(:render).with('baumler')
          helper.baumler_add
        end
      end
    end
  end
end
