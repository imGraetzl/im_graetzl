require 'rails_helper'

RSpec.describe Notifications::MandrillMessage do

  describe 'attributes' do
    let(:user) { build_stubbed :user }
    let(:mandrill_message) { Notifications::MandrillMessage.new user}

    it 'has template_name' do
      expect(mandrill_message).to respond_to :template_name
    end

    it 'has empty template_content' do
      expect(mandrill_message).to respond_to :template_content
      expect(mandrill_message.template_content).to eq []
    end

    it 'has message' do
      expect(mandrill_message).to respond_to :message
    end
  end

  describe '#basic_message_vars' do
    let(:user) { create :user }
    let(:mandrill_message) { Notifications::MandrillMessage.new user }

    subject(:vars) { mandrill_message.basic_message_vars }

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
end
