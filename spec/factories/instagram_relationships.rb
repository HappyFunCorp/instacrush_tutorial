FactoryGirl.define do
  factory :instagram_relationship do
    instagram_user_id 1
subject_user_id 1
followed_by false
follows false
interacted false
  end

end
