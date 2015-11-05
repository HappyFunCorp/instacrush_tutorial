# rails g model instagram_relationship instagram_user_id:integer:index subject_user_id:integer:index followed_by:boolean follows:boolean interacted:boolean

class InstagramRelationship < ActiveRecord::Base
  belongs_to :instagram_user
  belongs_to :subject_user, class_name: 'InstagramUser'

  def self.lookup_followers( instagram_client, instagram_user )
    logger.debug "Pulling in followers for #{instagram_user.username}"
    ret = instagram_client.user_follows( instagram_user.remote_id )

    stop = false
    while !stop
      ret.each do |follower|
        user = InstagramUser.from_hash follower
        relationship = instagram_user.relationships.where( subject_user_id: user.id ).first_or_create
        relationship.follows = true
        relationship.save
      end

      unless ret.pagination && ret.pagination['next_cursor']
        stop = true
      else
        logger.debug "Pulling in followers for #{instagram_user.username} #{ret.pagination['next_cursor']}"

        ret = instagram_client.user_follows( instagram_user.remote_id, cursor: ret.pagination['next_cursor'] )

        stop = true if ret.length == 0
      end
    end
  end
end
