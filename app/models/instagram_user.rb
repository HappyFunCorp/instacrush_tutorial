class InstagramUser < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username, use: :slugged

  belongs_to :user

  has_many :posts, class_name: 'InstagramMedia'
  has_many :interactions, through: :posts, class_name: "InstagramInteraction"

  def slug
    username
  end

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
    u.remote_id ||= user_info['id']
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

  [
    :user_info, 
    :feed_info, 
    :interaction_info, 
    :followers_info, 
    :member_since, 
    :user_likes
  ].each do |attribute|
    define_method :"#{attribute}_stale?" do
      finished_at = "#{attribute}_finished_at"
      attributes[finished_at].nil? || attributes[finished_at] < 12.hours.ago
    end

    define_method :"sync_#{attribute}_needed?" do
      send( :"#{attribute}_stale?" ) && attributes["#{attribute}_state"] != "queued"
    end

    define_method :"sync_#{attribute}" do
      if send( "sync_#{attribute}_needed?" )
        send( "sync_#{attribute}!" )
      end
    end

    define_method :"sync_#{attribute}!" do
      update_attribute :"#{attribute}_queued_at", Time.now
      update_attribute :"#{attribute}_state", "queued"
      eval( "Sync#{attribute.to_s.camelize}Job" ).perform_later( self.id, self.user.id )
    end
  end

  # def sync_interaction_info!
  #   update_attribute :interaction_info_queued_at, Time.now
  #   update_attribute :interaction_info_state, "queued"
  #   SyncInteractionInfoJob.perform_later( self.id, self.user.id )
  # end
end