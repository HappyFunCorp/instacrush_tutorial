FactoryGirl.define do
  sequence :uid do |n|
    "person#{n}"
  end
end

FactoryGirl.define do
  factory :identity do
    user nil
    provider "MyString"
    accesstoken "MyString"
    uid
    name "MyString"
    email "MyString"
    nickname "MyString"
    image "MyString"
    phone "MyString"
    urls "MyString"
  end
end
