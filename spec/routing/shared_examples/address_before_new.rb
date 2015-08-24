shared_examples :address_before_new_routing do |resource|

  describe 'routes address_before_new' do

    it "routes POST /#{resource.pluralize}/new to #new" do
      expect(post: "/#{resource.pluralize}/new").to route_to(
        controller: resource.pluralize,
        action: 'new')
    end

    it "routes POST address_#{resource.pluralize} to #new" do
      expect(post: named_route(resource)).to route_to(
        controller: resource.pluralize,
        action: 'new')
    end
  end
end

def named_route(resource)
  public_send("address_#{resource.pluralize}_path")
end