require 'rails_helper'

RSpec.feature 'RackRewrite', type: :request do
  it '301 redirects requests with trailing slash' do
    get '/wien/'
    expect(response.status).to eq 301
    expect(response).to redirect_to('/wien')
  end
end
