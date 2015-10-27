json.array!(@instagram_users) do |instagram_user|
  json.extract! instagram_user, :id, :user_id, :last_synced, :username, :full_name, :profile_picture, :media_count, :followed_count, :following_count
  json.url instagram_user_url(instagram_user, format: :json)
end
