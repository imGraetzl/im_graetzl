require "rails_helper"

RSpec.describe MeetingsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/meetings").to route_to("meetings#index")
    end

    it "routes to #new" do
      expect(:get => "/meetings/new").to route_to("meetings#new")
    end

    it "routes to #show" do
      expect(:get => "/meetings/1").to route_to("meetings#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/meetings/1/edit").to route_to("meetings#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/meetings").to route_to("meetings#create")
    end

    it "routes to #update" do
      expect(:put => "/meetings/1").to route_to("meetings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/meetings/1").to route_to("meetings#destroy", :id => "1")
    end

  end
end
