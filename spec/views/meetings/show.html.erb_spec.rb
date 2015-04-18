require 'rails_helper'

RSpec.describe "meetings/show", type: :view do
  before(:each) do
    @meeting = assign(:meeting, Meeting.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
