require 'rails_helper'

RSpec.describe 'locations/_location', type: :view do
  let(:location) { build_stubbed(:location) }

  describe 'map' do
    context 'without address' do
      before do
        allow(location).to receive(:address) { nil }
        render 'locations/location', location: location
      end

      it 'displays location avatar' do
        expect(rendered).to have_selector('img.location.avatar')
      end

      it 'does not display location map' do
        expect(rendered).not_to have_selector('img.locationMap')
      end

    end
    context 'with invalid address (without coordinates)' do
      before do
        allow(location.address).to receive(:coordinates) { nil }
        render 'locations/location', location: location
      end

      it 'displays location avatar' do
        expect(rendered).to have_selector('img.location.avatar')
      end

      it 'does not display location map' do
        expect(rendered).not_to have_selector('img.locationMap')
      end
    end
    context 'with valid address' do
      before do
        render 'locations/location', location: location
      end

      it 'displays location avatar' do
        expect(rendered).to have_selector('img.location.avatar')
      end

      it 'displays location map' do
        expect(rendered).to have_selector('img.locationMap')
      end
    end
  end
end