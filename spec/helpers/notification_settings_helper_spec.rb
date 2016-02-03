require 'rails_helper'

RSpec.describe NotificationSettingsHelper, type: :helper do

  describe '#notification_settings_mail_options' do
    let(:full_options) { [['off', 'Aus'], ['immediate', 'Sofort'], ['daily', 'Täglich']] }
    let(:min_options) { [['off', 'Aus'], ['immediate', 'Sofort']] }

    context 'when :daily available' do
      let(:type) { Notifications::NewMeeting }

      it 'returns full options array' do
        expect(helper.notification_settings_mail_options(type)).to eq full_options
      end

      it 'includes option for daily' do
        expect(helper.notification_settings_mail_options(type)).to include(['daily', 'Täglich'])
      end
    end

    context 'when :daily not available' do
      let(:type) { Notifications::CommentInMeeting }

      it 'returns min options array' do
        expect(helper.notification_settings_mail_options(type)).to eq min_options
      end

      it 'includes option for daily' do
        expect(helper.notification_settings_mail_options(type)).not_to include(['daily', 'Täglich'])
      end
    end
  end
end
