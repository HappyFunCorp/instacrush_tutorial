class Crush < ActiveRecord::Base
  belongs_to :user
  belongs_to :instagram_user
  belongs_to :crush_user, class_name: InstagramUser

  def self.find_for_user( user )
    return nil if user.instagram_user.nil?

    top_crush = user.instagram_user.top_interactors.first

    instagram_user_id = user.instagram_user.id
    crush_user_id = top_crush[:instagram_user_id]
    interactions = top_crush[:count].to_i
    likes = top_crush[:liked].to_i

    c = Crush.where( instagram_user_id: instagram_user_id, crush_user_id: crush_user_id ).first_or_create

    # Always update likes and comments count if needed
    c.likes_count = likes
    c.comments_count = interactions - likes

    c.save

    c
  end
end