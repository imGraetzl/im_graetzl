require 'rails_helper'
require 'mailers/shared/zuckerl_mailer'
include Stubs::MandrillApi

RSpec.describe Zuckerl::BookingConfirmation do
  before do
    allow_any_instance_of(Zuckerl).to receive :send_booking_confirmation
    stub_mandrill_api!
  end

  let(:mandrill_url) {
    'https://mandrillapp.com/api/1.0/messages/send-template.json' }

  describe 'attributes' do
    let!(:user) { create :user }
    let!(:location) { create :location, :approved }
    let!(:ownership) { create :location_ownership, user: user, location: location }
    let!(:zuckerl) { create :zuckerl, location: location }

    subject { described_class.new zuckerl }

    it 'has private attribute @user' do
      expect(subject.send :user).to eq user
    end
    it 'has private attribute @zuckerl' do
      expect(subject.send :zuckerl).to eq zuckerl
    end
    it 'has private attribute @location' do
      expect(subject.send :location).to eq location
    end
    it 'has private attribute @template' do
      expect(subject.send :template).to eq 'zuckerl-booking-confirmation'
    end
    it 'has private attribute @message' do
      message = subject.send :message
      expect(message).to be_a Hash
      expect(message.keys).to contain_exactly(:to,
        :from_email, :from_name, :subject, :merge_vars)
    end
  end

  it_behaves_like :a_zuckerl_mailer
end
