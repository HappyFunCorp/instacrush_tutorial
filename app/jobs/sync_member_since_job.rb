class SyncMemberSinceJob < ActiveJob::Base
  queue_as :default

  def perform(instagram_user_id, user_id)
    user = User.find user_id

    instagram_user = InstagramUser.find( instagram_user_id )
    instagram_user.update_attribute( :member_since_started_at, Time.now )

    InstagramMedia.look_for_oldest user.instagram_client, instagram_user

    instagram_user.reload
    
    instagram_user.member_since_finished_at = Time.now
    instagram_user.member_since_state = "synced"
    instagram_user.save
  end
end
