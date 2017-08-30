require 'rails_helper'
require 'rake'

RSpec.describe 'Tasks' do

  describe 'db:cleanup' do
    before do
      Rake.application.rake_require 'tasks/db/cleanup'
      Rake::Task.define_task(:environment)
    end
    subject(:task) { Rake::Task['db:cleanup'] }
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
        expect(Activity.count).to eq 5
        expect(Activity.where('created_at < ?', 7.weeks.ago).count).to eq 3
      end

      it 'removes records older than 6 weeks', job: true do
        expect{
          task.invoke
        }.to change{Activity.count}.from(5).to(2)
        expect(Activity.where('created_at < ?', 7.weeks.ago).count).to eq 0
      end
    end
  end
end
