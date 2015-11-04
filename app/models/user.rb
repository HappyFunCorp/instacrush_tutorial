class User < ActiveRecord::Base
  has_one :instagram_user

  has_many :identities, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  def instagram
    identities.where( :provider => "instagram" ).first
  end

  def instagram_client
    @instagram_client ||= Instagram.client( access_token: instagram.accesstoken )
  end

  def should_sync?
    instagram_user.nil? || instagram_user.sync_needed?
  end

  def find_instagram_user
    if instagram_user.nil?
      self.instagram_user = InstagramUser.sync_from_user( self )
    end

    instagram_user
  end
end
