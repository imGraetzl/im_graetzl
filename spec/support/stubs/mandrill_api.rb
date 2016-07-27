module Stubs
  module MandrillApi
    def stub_mandrill_api!
      stub_const 'MANDRILL_API_KEY', 'somestring'
      stub_request(:post, mandrill_api_url).to_return(
        status: 200,
        headers: { 'content-type' => 'application/json'},
        body: {}.to_json)
    end

    def mandrill_url
      'https://mandrillapp.com/api/1.0/messages/send-template.json'
    end

    private

    def mandrill_api_url
      /.*mandrillapp.com\/api.*/
    end
  end
end
