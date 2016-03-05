require 'rails_helper'

RSpec.describe Activity, type: :model do

  it 'has a valid factory' do
    expect(build :activity).to be_valid
  end

  describe 'associations' do
    let(:activity) { build :activity }

    it 'has trackable' do
      expect(activity).to respond_to :trackable
    end

    it 'has owner' do
      expect(activity).to respond_to :owner
    end

    it 'has recipient' do
      expect(activity).to respond_to :recipient
    end
  end

  describe 'callbacks' do
    describe 'before_destroy' do
      let(:activity) { create :activity }

      it 'destroys associated notification records' do
        create_list :notification, 10, activity: activity
        expect{
          activity.destroy
        }.to change{Notification.count}.from(10).to 0
      end
    end
    describe 'after_commit' do
      it 'creates notifications' do
        notification_stub = class_double('Notification').as_stubbed_const
        expect(notification_stub).to receive(:receive_new_activity)
        create :activity
      end
    end
  end
end
