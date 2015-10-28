json.array!(@instagram_media) do |instagram_medium|
  json.extract! instagram_medium, :id, :instagram_user_id, :media_id, :media_type, :comments_count, :likes_count, :link, :thumbnail_url, :standard_url
  json.url instagram_medium_url(instagram_medium, format: :json)
end
