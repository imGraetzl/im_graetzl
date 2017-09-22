FactoryGirl.define do
  factory :room_offer do
    slogan "MyString"
    room_description "MyText"
    total_area "9.99"
    rented_area "9.99"
    daily_rent false
    longterm_rent false
    owner_description "MyText"
    tenant_description "MyText"
    slug "MyString"
    user nil
    location nil
  end
end
