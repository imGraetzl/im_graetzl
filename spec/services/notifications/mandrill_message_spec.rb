require 'rails_helper'

RSpec.describe Notifications::MandrillMessage do
  let(:user) { create :user }

  describe '_#basic_message_vars' do
    let(:mandrill_message) { Notifications::MandrillMessage.new user }

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
    let(:service) { Notifications::MandrillMessage.new user }

    context 'without message or template' do
      it 'does nothing' do
        expect(service.deliver).to eq nil
      end

      it 'does nothing with message' do
        service.instance_variable_set(:@message, 'something')
        expect(service.deliver).to eq nil
      end

      it 'does nothing with template_name' do
        service.instance_variable_set(:@template_name, 'something')
        expect(service.deliver).to eq nil
      end
    end

    context 'with message and template_name' do
      before do
        service.instance_variable_set(:@message, 'something')
        service.instance_variable_set(:@template_name, 'something')
      end

      it 'calls mandrill api (raise error without key)' do
        expect{
          service.deliver
        }.to raise_error(Mandrill::Error)
      end
    end
  end
end
