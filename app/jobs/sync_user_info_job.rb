class SyncUserInfoJob < ActiveJob::Base
  queue_as :default

  def perform(instagram_user_id, user_id)
    user = User.find user_id

    instagram_user = InstagramUser.find( instagram_user_id )
    instagram_user.update_attribute( :user_info_started_at, Time.now )

    instagram_user.sync_user_info_from_instagram user.instagram_client

    instagram_user.reload
    
    instagram_user.user_info_finished_at = Time.now
    instagram_user.user_info_state = "synced"
    instagram_user.save
  end
end
