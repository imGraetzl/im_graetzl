require 'rails_helper'

RSpec.describe MandrillMessage do
  let(:user) { create :user }

  before do
    stub_const('MANDRILL_API_KEY', 'somestring')
    stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").
      to_return(:status => 200,:body => '{"some":"thing"}', :headers => {"Content-Type"=> "application/json"})
  end

  describe '_#basic_message_vars' do
    let(:mandrill_message) { MandrillMessage.new user }

    subject(:vars) { mandrill_message.send(:basic_message_vars) }

    it 'returns array of hashs' do
      expect(vars).to all(be_an(Hash))
    end

    it 'contains username' do
      expect(vars).to include({name: 'username', content: user.username})
    end

    it 'contains edit_user_url' do
      expect(vars).to include({name: 'edit_user_url', content: 'http://test.yourhost.com/user/einstellungen'})
    end
  end

  describe '#deliver' do
    let(:service) { MandrillMessage.new user }

    context 'without message or template' do
      it 'does not call mandril api' do
        service.deliver
        expect(WebMock).not_to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end

      it 'does nothing with message' do
        service.instance_variable_set(:@message, 'something')
        service.deliver
        expect(WebMock).not_to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end

      it 'does nothing with template' do
        service.instance_variable_set(:@template, 'something')
        service.deliver
        expect(WebMock).not_to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end
    end

    context 'with message and template' do
      before do
        service.instance_variable_set(:@message, 'something')
        service.instance_variable_set(:@template, 'something')
      end

      it 'calls mandrill api (raise error without key)' do
        service.deliver
        expect(WebMock).to have_requested(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json')
      end
    end
  end
end
