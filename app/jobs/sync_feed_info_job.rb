class SyncFeedInfoJob < ActiveJob::Base
  queue_as :default

  def perform(instagram_user_id, user_id)
    user = User.find user_id

    instagram_user = InstagramUser.find( instagram_user_id )
    instagram_user.update_attribute( :feed_info_started_at, Time.now )

    InstagramMedia.recent_feed_for_user user.instagram_client, instagram_user

    instagram_user.reload

    instagram_user.recent_posts_count = instagram_user.posts.
      where( "created_at > ?", 6.months.ago ).count

    instagram_user.recent_likes_count = instagram_user.posts.
      where( "created_at > ?", 6.months.ago ).sum( "likes_count" )

    instagram_user.recent_comments_count = instagram_user.posts.
      where( "created_at > ?", 6.months.ago ).sum( "comments_count" )

    instagram_user.feed_info_finished_at = Time.now
    instagram_user.feed_info_state = "synced"
    instagram_user.save
  end
end