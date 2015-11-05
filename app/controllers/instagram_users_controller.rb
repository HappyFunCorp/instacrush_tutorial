class InstagramUsersController < ApplicationController
  before_filter :require_instagram_user
  # before_filter :require_fresh_user, only: [:index]
  before_action :load_stats, only: [:show]
 
  def index
    @users = InstagramUser.order( "updated_at desc" ).limit( 20 )
  end

  def show
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
    @instagram_user = InstagramUser.find_by_username( params[:username] )
    @top_interactors = @instagram_user.top_interactors.limit( 10 )
    @user_hash = {}
    InstagramUser.where( "id in (?)", @top_interactors.collect { |x| x[:instagram_user_id] } ).each do |user|
      @user_hash[user.id] = user
    end

    @oldest_followers = @instagram_user.subject_users.where( "member_since is not null" ).order( "member_since asc" ).limit( 10 )
    @newest_followers = @instagram_user.subject_users.where( "member_since is not null" ).order( "member_since desc" ).limit( 10 )

    @influencers_likes = @instagram_user.subject_users.where( "recent_likes_count > 0" ).order( "recent_likes_count desc").limit( 10 )
    @influencers_followers = @instagram_user.subject_users.where( "followed_count > 0" ).order( "followed_count desc").limit( 10 )

    @influencers_likes_per_post = @instagram_user.subject_users.where( "recent_likes_count > 0" ).order( "(recent_likes_count / recent_posts_count) desc").limit( 10 )
    @top_posts = @instagram_user.posts.order( "likes_count desc" ).limit( 6 )
    @top_likers = @instagram_user.top_interactors.collect { |x| x[:instagram_user_id]}
  end
end
