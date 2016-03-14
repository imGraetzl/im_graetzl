require 'rails_helper'

RSpec.describe BillingAddressesController, type: :routing do
  describe 'routes' do
    it 'routes GET /locations/location-slug/billing_address/new to #new' do
      expect(get: '/locations/location-slug/billing_address/new').not_to be_routable
    end

    it 'routes GET /locations/location-slug/billing_address/edit to #edit' do
      expect(get: '/locations/location-slug/billing_address/edit').not_to be_routable
    end

    it 'routes GET /zuckerls/zuckerl-slug/billing_address to #show' do
      expect(get: '/zuckerls/zuckerl-slug/billing_address').to route_to('billing_addresses#show', zuckerl_id: 'zuckerl-slug')
    end

    it 'routes POST /zuckerls/zuckerl-slug/billing_address to #create' do
      expect(post: '/zuckerls/zuckerl-slug/billing_address').to route_to('billing_addresses#create', zuckerl_id: 'zuckerl-slug')
    end

    it 'routes PUT /zuckerls/zuckerl-slug/billing_address to #update' do
      expect(put: '/zuckerls/zuckerl-slug/billing_address').to route_to('billing_addresses#update', zuckerl_id: 'zuckerl-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET zuckerl_billing_address to #show' do
      expect(get: zuckerl_billing_address_path(zuckerl_id: 'zuckerl-slug')).to route_to('billing_addresses#show', zuckerl_id: 'zuckerl-slug')
    end

    it 'routes POST zuckerl_billing_address to #create' do
      expect(post: zuckerl_billing_address_path(zuckerl_id: 'zuckerl-slug')).to route_to('billing_addresses#create', zuckerl_id: 'zuckerl-slug')
    end

    it 'routes PUT zuckerl_billing_address to #update' do
      expect(put: zuckerl_billing_address_path(zuckerl_id: 'zuckerl-slug')).to route_to('billing_addresses#update', zuckerl_id: 'zuckerl-slug')
    end
  end
end
