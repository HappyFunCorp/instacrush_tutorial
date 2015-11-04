class InstagramMediaController < ApplicationController
  before_filter :require_instagram_user
  # before_filter :require_fresh_user, only: [:index]
  before_action :set_instagram_medium, only: [:show]

  def index
    @instagram_media = current_user.instagram_user.posts.order( "likes_count desc" )
  end 

  def show    
    @instagram_medium = InstagramMedia.find(params[:id])
  end 
end