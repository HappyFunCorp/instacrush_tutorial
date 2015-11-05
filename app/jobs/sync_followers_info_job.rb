class SyncFollowersInfoJob < ActiveJob::Base
  queue_as :default

  def perform(instagram_user_id, user_id)
    user = User.find user_id

    instagram_user = InstagramUser.find( instagram_user_id )
    instagram_user.update_attribute( :followers_info_started_at, Time.now )

    InstagramRelationship.lookup_followers( user.instagram_client, instagram_user )

    instagram_user.reload

    instagram_user.relationships.where( follows: true ).each do |relationship|
      follow_user = relationship.subject_user
      follow_user.sync_user_info user_id
      follow_user.sync_feed_info user_id
      follow_user.sync_member_since user_id
    end

    instagram_user.followers_info_finished_at = Time.now
    instagram_user.followers_info_state = "synced"
    instagram_user.save
  end
end