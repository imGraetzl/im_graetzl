require 'rails_helper'

RSpec.describe 'Tasks' do

  describe 'db:truncate' do
    before do
      ImGraetzl::Application.load_tasks
      ENV['ALLOW_WORKER'] = 'true'
    end
    subject(:task) { Rake::Task['db:truncate'] }
    before(:example) { task.reenable }

    it 'does not raise exception' do
      expect{
        task.invoke
      }.not_to raise_exception
    end

    context 'when notifications older than 2 weeks' do
      before do
        3.times{create(:notification, created_at: 3.weeks.ago)}
        2.times{create(:notification)}
      end

      it 'has old and new Notification records in db' do
        expect(Notification.count).to eq 5
        expect(Notification.where('created_at < ?', 2.weeks.ago).count).to eq 3
      end

      it 'removes records older than 2 weeks' do
        expect{
          task.invoke
        }.to change{Notification.count}.from(5).to(2)
        expect(Notification.where('created_at < ?', 2.weeks.ago).count).to eq 0
      end
    end

    context 'when activity older than 6 weeks' do
      before do
        3.times{create(:activity, created_at: 7.weeks.ago, key: nil)}
        2.times{create(:activity, key: nil)}
      end

      it 'has old and new activity records in db', job: true do
        expect(PublicActivity::Activity.count).to eq 5
        expect(PublicActivity::Activity.where('created_at < ?', 7.weeks.ago).count).to eq 3
      end

      it 'removes records older than 6 weeks', job: true do
        expect{
          task.invoke
        }.to change{PublicActivity::Activity.count}.from(5).to(2)
        expect(PublicActivity::Activity.where('created_at < ?', 7.weeks.ago).count).to eq 0
      end
    end
  end
end
