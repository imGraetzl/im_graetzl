require 'rails_helper'

RSpec.describe "meetings/index", type: :view do
  before(:each) do
    assign(:meetings, [
      Meeting.create!(),
      Meeting.create!()
    ])
  end

  it "renders a list of meetings" do
    render
  end
end
