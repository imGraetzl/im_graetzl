require 'rails_helper'

RSpec.describe WorkerController, type: :routing do
  describe 'routing' do

    it 'routes /worker/daily_mail to #daily_mail' do
      expect(post: '/worker/daily_mail').to route_to('worker#daily_mail')
    end

    it 'routes /worker/weekly_mail to #weekly_mail' do
      expect(post: '/worker/weekly_mail').to route_to('worker#weekly_mail')
    end
  end
end
