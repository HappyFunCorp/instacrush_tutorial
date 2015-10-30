class InstagramInteraction < ActiveRecord::Base
  belongs_to :instagram_media
  belongs_to :instagram_user
end
