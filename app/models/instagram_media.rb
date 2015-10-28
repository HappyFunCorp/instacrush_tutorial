class InstagramMedia < ActiveRecord::Base
  belongs_to :instagram_user

  has_many :interactions, class_name: 'InstagramInteraction'

  def comments
    interactions.where( is_like: false )
  end

  def likes
    interactions.where( is_like: true )
  end

  def self.recent_feed_for_user( user )
    self_user = InstagramUser.sync_from_user( user )

    user.instagram_client.user_recent_media.each do |media|
      InstagramMedia.reify( media, self_user, user.instagram_client )
    end
  end

  def self.reify( media, instagram_user, client )
    p = where( media_id: media['id'] ).first_or_create
    p.instagram_user = instagram_user
    p.media_type = media['type']
    p.link = media['link']
    p.thumbnail_url = media['images']['thumbnail']['url']
    p.standard_url = media['images']['standard_resolution']['url']
    p.comments_count = media['comments']['count']
    p.likes_count = media['likes']['count']
    p.created_at = Time.at( media['created_time'].to_i )

    media['comments']['data'].each do |comment|
      commentor = InstagramUser.from_hash( comment['from'] )
      InstagramInteraction.where( instagram_media_id: p.id, instagram_user_id: commentor.id, is_like: false ).first_or_create do |interaction|
        interaction.comment = comment['text']
        interaction.created_at = Time.at( comment['created_time'].to_i )
      end
    end

    client.media_likes( media['id'] ).each do |like|
      liker = InstagramUser.from_hash( like )
      InstagramInteraction.where( instagram_media_id: p.id, instagram_user_id: liker.id, is_like: true ).first_or_create
    end

    p.save
  end
end