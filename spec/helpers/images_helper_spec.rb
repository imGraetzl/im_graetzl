require 'rails_helper'

RSpec.describe ImagesHelper, type: :helper do
  describe '.avatar_for' do
    context 'when passing a user' do
      let(:fallback_regex) { /<img.*"attachment user avatar img-round fallback".*\/>/ }
      let(:avatar_regex) { /<img.*"attachment user avatar img-round".*\/>/ }
      let(:resource) { build :user }

      it 'returns a 200 by 200 fallback image if no uploaded image' do
        expect(helper.avatar_for resource).to match fallback_regex
      end

      it 'returns a 200 by 200 avatar image' do
        allow(resource).to receive(:avatar_id){123456789}
        expect(helper.avatar_for resource).to match avatar_regex
      end
    end
    context 'when passing a location' do
      let(:fallback_regex) { /<img.*"attachment location avatar img-square fallback".*\/>/ }
      let(:avatar_regex) { /<img.*"attachment location avatar img-square".*\/>/ }
      let(:resource) { build :location }

      it 'returns a 200 by 200 fallback image if no uploaded image' do
        expect(helper.avatar_for resource).to match fallback_regex
      end

      it 'returns a 200 by 200 avatar image' do
        allow(resource).to receive(:avatar_id){123456789}
        expect(helper.avatar_for resource).to match avatar_regex
      end
    end
  end
end
