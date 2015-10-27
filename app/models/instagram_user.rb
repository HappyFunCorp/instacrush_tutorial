class InstagramUser < ActiveRecord::Base
  belongs_to :user

  def self.sync_from_user( user )
    user_info = user.instagram_client.user

    u = where( :username => user_info['username']).first_or_create
    u.user_id = user.id
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
end
