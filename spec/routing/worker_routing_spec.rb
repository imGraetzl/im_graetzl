require 'rails_helper'

RSpec.describe WorkerController, type: :routing do
  describe 'routing' do

    it 'routes /worker/daily_mail to #daily_mail' do
      expect(post: '/worker/daily_mail').to route_to('worker#daily_mail')
    end

    it 'routes /worker/weekly_mail to #weekly_mail' do
      expect(post: '/worker/weekly_mail').to route_to('worker#weekly_mail')
    end

    it 'routes /worker/backup to #backup' do
      expect(post: '/worker/backup').to route_to('worker#backup')
    end

    it 'routes /worker/truncate_db to #truncate_db' do
      expect(post: '/worker/truncate_db').to route_to('worker#truncate_db')
    end

    it 'routes /worker/truncate_eb to #truncate_eb' do
      expect(post: '/worker/truncate_eb').to route_to('worker#truncate_eb')
    end
  end
end
