FactoryGirl.define do
  factory :instagram_medium, :class => 'InstagramMedia' do
    instagram_user nil
    media_id "MyString"
    media_type "MyString"
    comments_count 1
    likes_count 1
    link "MyString"
    thumbnail_url "MyString"
    standard_url "MyString"
  end
end
