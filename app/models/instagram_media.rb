class InstagramMedia < ActiveRecord::Base
  belongs_to :instagram_user

  has_many :interactions, class_name: 'InstagramInteraction'

  def comments
    interactions.where( is_like: false )
  end

  def likes
    interactions.where( is_like: true )
  end

  def self.recent_feed_for_user( instagram_client, instagram_user, comments = false )
    logger.debug "Pulling in recent feed for #{instagram_user.username}"
    ret = instagram_client.user_recent_media( instagram_user.remote_id )

    skipped = false
    while !skipped
      ret.each do |media|
        if Time.at(media['created_time'].to_i) > 6.months.ago
          self.reify( media, comments )
        else
          logger.debug "Found a post too old #{Time.at(media['created_time'].to_i)}" if !skipped
          skipped = true
        end
      end

      if !skipped
        logger.debug "Looking up next page of results"
        ret = instagram_client.user_recent_media( instagram_user.remote_id, max_id: ret.pagination['next_max_id'] )
        skipped = true if ret.length == 0
      end
    end
  end

  def self.reify( media, save_comments = false )
    instagram_user = InstagramUser.from_hash media['user']

    p = where( media_id: media['id'] ).first_or_create

    p.instagram_user = instagram_user
    p.media_type = media['type']
    p.link = media['link']
    p.thumbnail_url = media['images']['thumbnail']['url']
    p.standard_url = media['images']['standard_resolution']['url']
    p.comments_count = media['comments']['count']
    p.likes_count = media['likes']['count']
    p.created_at = Time.at( media['created_time'].to_i )

    p.save

    if save_comments
      media['comments']['data'].each do |comment|
        commentor = InstagramUser.from_hash( comment['from'] )
        InstagramInteraction.where( instagram_media_id: p.id, instagram_user_id: commentor.id, is_like: false ).first_or_create do |interaction|
          interaction.comment = comment['text']
          interaction.created_at = Time.at( comment['created_time'].to_i )
        end
      end
    end
  end

  def self.look_for_oldest( instagram_client, instagram_user )
    logger.debug "look_for_oldest for #{instagram_user.username}"
    start_month = 6*12 # Start looking 6 years ago
    ret = []
    while ret.length == 0 && start_month > 0
      ret = instagram_client.user_recent_media( instagram_user.remote_id, max_timestamp: start_month.months.ago.to_i )
      if ret.last
        logger.debug "Latest is #{ret.last["created_time"]}"
      else
        logger.debug  "Nothing for #{start_month/12} years ago"
      end
      start_month -= 6
    end

    last_media = ret.last
    logger.debug  "Latest is #{ret.last["created_time"]}"
    while ret.last
      ret = instagram_client.user_recent_media( instagram_user.remote_id, max_id: ret.pagination["next_max_id"], count: 50 )
      logger.debug  "#{ret.length} results"
      last_media = ret.last || last_media
      logger.debug  "Latest is #{ret.last["created_time"]}" if ret.last
    end

    if last_media
      logger.debug "Setting member_since to #{last_media["created_time"]}"
      instagram_user.update_attribute( :member_since, Time.at(last_media["created_time"].to_i) )
    else
      logger.debug "No last_media found"
    end
    last_media
  end

  def load_interaction_data( instagram_client )
    instagram_client.media_likes( media_id ).each do |like|
      liker = InstagramUser.from_hash( like )
      InstagramInteraction.where( instagram_media_id: id, instagram_user_id: liker.id, is_like: true ).first_or_create
    end
  end
end