shared_examples :post_new do |resource|

  describe 'routes address_before_new' do

    it "routes POST /#{resource.pluralize}/new to #new" do
      expect(post: "/graetzl_slug/#{resource.pluralize}/new").to route_to(
        controller: resource.pluralize,
        action: 'new',
        graetzl_id: 'graetzl_slug')
    end

    it "routes POST address_new_graetzl_#{resource.pluralize} to #new" do
      expect(post: named_route(resource)).to route_to(
        controller: resource.pluralize,
        action: 'new',
        graetzl_id: 'graetzl_slug')
    end
  end
end

def named_route(resource)
  public_send("address_graetzl_#{resource.pluralize}_path", graetzl_id: 'graetzl_slug')
end