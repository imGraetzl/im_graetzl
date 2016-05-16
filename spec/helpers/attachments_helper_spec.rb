require 'rails_helper'

RSpec.describe AttachmentsHelper, type: :helper do
  describe '.avatar_for' do
    context 'when passing a user' do
      let(:fallback_regex) { /<img.*"attachment user avatar img-round fallback".*\/>/ }
      let(:avatar_regex) { /<img.*"attachment user avatar img-round".*\/>/ }
      let(:resource) { build :user }

      it 'returns fallback if no uploaded image' do
        expect(helper.avatar_for resource).to match fallback_regex
      end

      it 'returns avatar image' do
        allow(resource).to receive(:avatar_id){123456789}
        expect(helper.avatar_for resource).to match avatar_regex
      end
    end
    context 'when passing a location' do
      let(:fallback_regex) { /<img.*"attachment location avatar img-square fallback".*\/>/ }
      let(:avatar_regex) { /<img.*"attachment location avatar img-square".*\/>/ }
      let(:resource) { build :location }

      it 'returns fallback image if no uploaded image' do
        expect(helper.avatar_for resource).to match fallback_regex
      end

      it 'returns avatar image' do
        allow(resource).to receive(:avatar_id){123456789}
        expect(helper.avatar_for resource).to match avatar_regex
      end
    end
  end
  describe '.cover_photo_for' do
    let(:fallback_regex) { /<img.*"attachment (user|location) cover_photo coverImg fallback".*\/>/ }
    let(:cover_photo_regex) { /<img.*"attachment (user|location) cover_photo coverImg".*\/>/ }
    let(:resource) { build :user }

    context 'when photo exists' do
      before { allow(resource).to receive(:cover_photo_id){12345678} }

      it 'returns image' do
        expect(helper.cover_photo_for resource).to match cover_photo_regex
      end
    end
    context 'when no photo' do
      it 'returns fallback' do
        expect(helper.cover_photo_for resource).to match fallback_regex
      end
    end
  end
end
