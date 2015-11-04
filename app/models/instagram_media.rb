class InstagramMedia < ActiveRecord::Base
  belongs_to :instagram_user

  has_many :interactions, class_name: 'InstagramInteraction'

  def comments
    interactions.where( is_like: false )
  end

  def likes
    interactions.where( is_like: true )
  end

  def self.recent_feed_for_user( instagram_client, instagram_user )
    instagram_client.user_recent_media( instagram_user.remote_id ).each do |media|
      self.reify( media )
    end
  end

  def self.reify( media )
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

    media['comments']['data'].each do |comment|
      commentor = InstagramUser.from_hash( comment['from'] )
      InstagramInteraction.where( instagram_media_id: p.id, instagram_user_id: commentor.id, is_like: false ).first_or_create do |interaction|
        interaction.comment = comment['text']
        interaction.created_at = Time.at( comment['created_time'].to_i )
      end
    end
  end

  def load_interaction_data( instagram_client )
    instagram_client.media_likes( media_id ).each do |like|
      liker = InstagramUser.from_hash( like )
      InstagramInteraction.where( instagram_media_id: id, instagram_user_id: liker.id, is_like: true ).first_or_create
    end
  end
end