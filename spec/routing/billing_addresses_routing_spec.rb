require 'rails_helper'
require 'routing/shared/address_before_new'

RSpec.describe BillingAddressesController, type: :routing do

  describe 'routing' do
    it 'routes GET /locations/location-slug/billing_address/new to #new' do
      expect(get: '/locations/location-slug/billing_address/new').not_to be_routable
    end

    it 'routes GET /locations/location-slug/billing_address/edit to #edit' do
      expect(get: '/locations/location-slug/billing_address/edit').not_to be_routable
    end

    it 'routes GET /zuckerls/zuckerl-slug/billing_address to #show' do
      expect(get: '/zuckerls/zuckerl-slug/billing_address').to route_to(
        controller: 'billing_addresses',
        action: 'show',
        zuckerl_id: 'zuckerl-slug')
    end

    it 'routes GET zuckerl_billing_address to #show' do
      expect(get: zuckerl_billing_address_path(zuckerl_id: 'zuckerl-slug')).to route_to(
        controller: 'billing_addresses',
        action: 'show',
        zuckerl_id: 'zuckerl-slug')
    end

    it 'routes POST zuckerl_billing_address to #create' do
      expect(post: zuckerl_billing_address_path(zuckerl_id: 'zuckerl-slug')).to route_to(
        controller: 'billing_addresses',
        action: 'create',
        zuckerl_id: 'zuckerl-slug')
    end

    it 'routes PUT zuckerl_billing_address to #create' do
      expect(put: zuckerl_billing_address_path(zuckerl_id: 'zuckerl-slug')).to route_to(
        controller: 'billing_addresses',
        action: 'update',
        zuckerl_id: 'zuckerl-slug')
    end
  end
end
