require 'rails_helper'

RSpec.describe Zuckerl::Invoice do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation).and_return true
  end

  let(:location) { create :location }
  let(:zuckerl) { create :zuckerl, location: location }

  before do
    create :location_ownership, location: location
    stub_const('MANDRILL_API_KEY', 'somestring')
    stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").
      to_return(:status => 200,:body => '{"some":"thing"}', :headers => {"Content-Type"=> "application/json"})
  end

  describe '_#build_message' do
    let(:service) { Zuckerl::Invoice.new zuckerl }
    subject(:message_hash) { service.send(:build_message) }

    it 'has keys for mandrill' do
      expect(message_hash.keys).to contain_exactly(
        :to,
        :from_email,
        :from_name,
        :subject,
        :merge_vars,
        :bcc_address)
    end

    it 'has merge_vars' do
      expect(message_hash[:merge_vars]).to be_a(Array)
      expect(message_hash[:merge_vars][0]).to be_a(Hash)
      expect(message_hash[:merge_vars][0][:vars]).not_to be_empty
    end

    it 'has bcc_address' do
      expect(message_hash[:bcc_address]).to eq 'rechnung@imgraetzl.at'
    end
  end

  describe '_#billing_address_vars' do
    let(:service) { Zuckerl::Invoice.new zuckerl }
    subject(:message_hash) { service.send(:billing_address_vars) }

    context 'when location has billing_address' do
      before { create :billing_address, location: location }

      it 'returns var hash' do
        expect(message_hash).not_to be_nil
      end
    end
    context 'when location has no billing_address' do
      it 'returns nil' do
        expect(message_hash).to eq nil
      end
    end
  end

  describe '#deliver' do
    let(:service) { Zuckerl::Invoice.new zuckerl }

    context 'with message' do
      before { allow(service).to receive(:build_message){{to: 'user@example.com'}} }

      it 'calls mandrill api' do
        service.deliver
        expect(WebMock).to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end
    end

    context 'without message' do
      before { allow(service).to receive(:build_message) }

      it 'does not call mandrill api' do
        service.deliver
        expect(WebMock).not_to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end
    end
  end
end
