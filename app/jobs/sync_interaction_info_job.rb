class SyncInteractionInfoJob < ActiveJob::Base
  queue_as :default

  def perform(instagram_user_id, user_id)
    user = User.find user_id

    instagram_user = InstagramUser.find( instagram_user_id )
    instagram_user.update_attribute( :interaction_info_started_at, Time.now )

    InstagramMedia.recent_feed_for_user user.instagram_client, instagram_user, true

    instagram_user.reload

    instagram_user.posts.each do |post|
      post.load_interaction_data( user.instagram_client )
    end

    instagram_user.interaction_info_finished_at = Time.now
    instagram_user.interaction_info_state = "synced"
    instagram_user.save
  end
end
