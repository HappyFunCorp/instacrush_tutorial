 
 
class InstagramMediaController < ApplicationController
  before_action :set_instagram_medium, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json, :js

  def index
    @instagram_media = InstagramMedia.all
  end 

  def show
  end 

  def new 
    @instagram_medium = InstagramMedia.new
  end 

  def edit
  end 

  def create
    @instagram_medium = InstagramMedia.new(instagram_medium_params)
    @instagram_medium.save
    respond_with(@instagram_medium)
  end 

  def update
    @instagram_medium.update(instagram_medium_params)
    flash[:notice] = 'Instagram media was successfully updated.'
    respond_with(@instagram_medium)
  end 

  def destroy
    @instagram_medium.destroy
    redirect_to instagram_media_index_url, notice: 'Instagram media was successfully destroyed.'
  end 

  private
    def set_instagram_medium
      @instagram_medium = InstagramMedia.find(params[:id])
    end 

    def instagram_medium_params
      params.require(:instagram_medium).permit(:instagram_user_id, :media_id, :media_type, :comments_count, :likes_count, :link, :thumbnail_url, :standard_url) 
    end 
end
 
