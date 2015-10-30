class InstagramUser < ActiveRecord::Base
  belongs_to :user

  has_many :posts, class_name: 'InstagramMedia'
  has_many :interactions, through: :posts, class_name: "InstagramInteraction"

  def nearby_users
    query = InstagramUser #.select "instagram_users.*"
    query = InstagramUser.from "instagram_users, instagram_media, instagram_interactions"
    query = query.where "instagram_media.instagram_user_id = #{self.id}"
    query = query.where "instagram_media.id = instagram_interactions.instagram_media_id"
    query = query.where "instagram_interactions.instagram_user_id = instagram_users.id"
  end

  def self.sync_from_user( user )
    user_info = user.instagram_client.user

    from_hash user_info, user
  end

  def self.from_hash user_info, user = nil
    u = where( :username => user_info['username']).first_or_create
    u.user_id = user.id if user
    u.username = user_info['username']
    u.full_name = user_info['full_name']
    u.profile_picture = user_info['profile_picture']
    if user_info['counts']
      u.media_count = user_info['counts']['media']
      u.followed_count = user_info['counts']['followed_by']
      u.following_count = user_info['counts']['follows']
    end
    
    u.save

    u
  end

  def top_interactors
    interactions.
      select( [
              "instagram_interactions.instagram_user_id", 
              "count(*) as count",
              "sum(case is_like when 't' then 1 else 0 end) as liked"
              ].join( ',') ).
      group( :instagram_user_id ).
      order( "count desc" )
  end
end
