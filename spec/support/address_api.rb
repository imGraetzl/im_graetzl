module Stubs
  module AddressApi
    def stub_address_api!
      stub_request(:get, api_url).
        to_return(
          status: 200,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
          body: {}.to_json)
    end

    private

    def api_url
      @api_url ||= /.*data.wien.gv.at.*/
    end
  end
end
