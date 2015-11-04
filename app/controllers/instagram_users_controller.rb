class InstagramUsersController < ApplicationController
  before_filter :require_instagram_user
  # before_filter :require_fresh_user, only: [:index]
  before_action :load_stats
 
  def index
  end

  def show
    @user = InstagramUser.find_by_username( params[:username] )
    @instagram_media = @instagram_user.
      posts.
      joins( :interactions ).
      where( instagram_interactions: { instagram_user_id: @user.id } ).
      order( "likes_count desc")
    render :index
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
