require 'rails_helper'

RSpec.describe Notifications::ImmediateMail do

  describe '.build_message' do
    let(:activity) { build_stubbed(:activity,
                      trackable: build_stubbed(:meeting),
                      owner: build_stubbed(:user)) }
    let(:notification) { build_stubbed(:notification_new_meeting,
                          activity: activity) }
    let(:immediate_mail) { Notifications::ImmediateMail.new notification }

    subject(:message_hash) { immediate_mail.build_message }

    it 'has keys for mandrill' do
      expect(message_hash.keys).to include(:to,
                                            :from_email,
                                            :from_name,
                                            :subject,
                                            :merge_vars)
    end
  end
end
