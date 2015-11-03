class UpdateUserFeedJob < ActiveJob::Base
  queue_as :default

  def perform( user_id )
    user = User.find user_id

    InstagramMedia.recent_feed_for_user user

    user.reload
    
    instagram_user = user.instagram_user
    instagram_user.state = "synced"
    instagram_user.last_synced = Time.now
    instagram_user.save
  end
end
