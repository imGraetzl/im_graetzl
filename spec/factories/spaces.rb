FactoryGirl.define do
  factory :space do
    slug "MyString"
    slogan "MyString"
    description "MyText"
    total_area 1
    rented_area 1
    daily false
    longterm false
    owner_description "MyText"
    tenant_description "MyText"
    collaboration false
    location nil
  end
end
