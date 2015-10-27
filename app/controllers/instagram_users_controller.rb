 
 
class InstagramUsersController < ApplicationController
  before_action :set_instagram_user, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json, :js

  def index
    @instagram_users = InstagramUser.all
  end 

  def show
  end 

  def new 
    @instagram_user = InstagramUser.new
  end 

  def edit
  end 

  def create
    @instagram_user = InstagramUser.new(instagram_user_params)
    @instagram_user.save
    respond_with(@instagram_user)
  end 

  def update
    @instagram_user.update(instagram_user_params)
    flash[:notice] = 'Instagram user was successfully updated.'
    respond_with(@instagram_user)
  end 

  def destroy
    @instagram_user.destroy
    redirect_to instagram_users_url, notice: 'Instagram user was successfully destroyed.'
  end 

  private
    def set_instagram_user
      @instagram_user = InstagramUser.find(params[:id])
    end 

    def instagram_user_params
      params.require(:instagram_user).permit(:user_id, :last_synced, :username, :full_name, :profile_picture, :media_count, :followed_count, :following_count) 
    end 
end
 
