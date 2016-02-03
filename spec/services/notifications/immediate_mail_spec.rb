require 'rails_helper'

RSpec.describe Notifications::ImmediateMail do
  let(:activity) { build_stubbed(:activity,
    trackable: build_stubbed(:meeting),
    owner: build_stubbed(:user)) }
  let(:notification) { build_stubbed(:notification_new_meeting,
    activity: activity) }

  before do
    stub_const('MANDRILL_API_KEY', 'somestring')
    stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").
         to_return(:status => 200,:body => '{"some":"thing"}', :headers => {"Content-Type"=> "application/json"})
  end

  describe '_#build_message' do
    let(:service) { Notifications::ImmediateMail.new notification }

    subject(:message_hash) { service.send(:build_message) }

    it 'has keys for mandrill' do
      expect(message_hash.keys).to contain_exactly(:to,
                                            :from_email,
                                            :from_name,
                                            :subject,
                                            :global_merge_vars,
                                            :merge_vars)
    end

    it 'has keys for immediate mail' do
      expect(message_hash[:merge_vars]).to be_a(Array)
      expect(message_hash[:merge_vars][0]).to be_a(Hash)
      expect(message_hash[:merge_vars][0][:vars]).not_to be_empty
    end
  end

  describe '#deliver' do
    let(:service) { Notifications::ImmediateMail.new(notification) }

    context 'when message available' do
      before { allow(service).to receive(:build_message){[{name: 'something'}]} }

      it 'calls mandrill api' do
        service.deliver
        expect(WebMock).to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end
    end

    context 'when no message available' do
      before { allow(service).to receive(:build_message) }

      it 'does nothing' do
        expect(service.deliver).to eq nil
      end

      it 'does not call mandrill api' do
        service.deliver
        expect(WebMock).not_to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')        
      end
    end
  end
end
