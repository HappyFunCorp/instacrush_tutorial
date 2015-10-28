json.array!(@instagram_interactions) do |instagram_interaction|
  json.extract! instagram_interaction, :id, :instagram_media_id, :instagram_user_id, :comment, :is_like
  json.url instagram_interaction_url(instagram_interaction, format: :json)
end
