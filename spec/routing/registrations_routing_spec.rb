require "rails_helper"

RSpec.describe RegistrationsController, type: :routing do

  describe 'routing' do

    it 'routes GET registrierung/adresse to #address' do
      expect(get: 'users/registrierung/adresse').to route_to('registrations#address')
    end

    it 'routes POST registrierung/adresse to #set_address' do
      expect(post: 'users/registrierung/adresse').to route_to('registrations#set_address')
    end

    it 'routes GET registrierung/graetzl to #graetzl' do
      expect(get: 'users/registrierung/graetzl').to route_to('registrations#graetzl')
    end

    it 'routes xhr GET registrierung/graetzl to #graetzl' do
      expect(get: 'users/registrierung/graetzl', format: :xhr).to route_to('registrations#graetzl')
    end

    it 'routes POST registrierung/graetzl to #set_graetzl' do
      expect(post: 'users/registrierung/graetzl').to route_to('registrations#set_graetzl')
    end
  end
  

  describe 'named route helpers' do

    it 'routes GET to #address' do
      expect(get: user_registration_address_path).to route_to('registrations#address')
    end

    it 'routes POST to #set_address' do
      expect(post: user_registration_set_address_path).to route_to('registrations#set_address')
    end

    it 'routes GET to #graetzl' do
      expect(get: user_registration_graetzl_path).to route_to('registrations#graetzl')
    end

    it 'routes POST to #set_graetzl' do
      expect(post: user_registration_set_graetzl_path).to route_to('registrations#set_graetzl')
    end
  end
end