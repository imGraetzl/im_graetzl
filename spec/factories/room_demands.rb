FactoryGirl.define do
  factory :room_demand do
    slogan "MyString"
    needed_area "9.99"
    daily_rent false
    longterm_rent false
    demand_description "MyText"
    personal_description "MyText"
    wants_collaboration false
    slug "MyString"
    user nil
  end
end
