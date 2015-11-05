class InstagramUsersController < ApplicationController
  before_filter :require_instagram_user
  # before_filter :require_fresh_user, only: [:index]
  before_action :load_stats
 
  def index
    @instagram_user = current_user.instagram_user
    render :show
  end

  def show
    @instagram_user = InstagramUser.find_by_username( params[:username] )
  end

  def sync
    @instagram_user = InstagramUser.find_by_username( params[:username] )
    [
      :user_info, 
      :feed_info, 
      :interaction_info, 
      :followers_info, 
      :member_since, 
      :user_likes
    ].each do |feed|
      @instagram_user.send( :"sync_#{feed}", current_user.id)
    end

    redirect_to @instagram_user, notice: "Syncing queued"
  end

  private
  def load_stats
    @instagram_user = current_user.instagram_user

    @top_users = @instagram_user.top_interactors.limit( 10 )
    @user_hash = {}
    InstagramUser.where( "id in (?)", @top_users.collect { |x| x[:instagram_user_id] } ).each do |user|
      @user_hash[user.id] = user
    end
    @instagram_media = @instagram_user.posts.order( "likes_count desc" )
  end
end
