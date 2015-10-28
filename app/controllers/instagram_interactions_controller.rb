 
 
class InstagramInteractionsController < ApplicationController
  before_action :set_instagram_interaction, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json, :js

  def index
    @instagram_interactions = InstagramInteraction.all
  end 

  def show
  end 

  def new 
    @instagram_interaction = InstagramInteraction.new
  end 

  def edit
  end 

  def create
    @instagram_interaction = InstagramInteraction.new(instagram_interaction_params)
    @instagram_interaction.save
    respond_with(@instagram_interaction)
  end 

  def update
    @instagram_interaction.update(instagram_interaction_params)
    flash[:notice] = 'Instagram interaction was successfully updated.'
    respond_with(@instagram_interaction)
  end 

  def destroy
    @instagram_interaction.destroy
    redirect_to instagram_interactions_url, notice: 'Instagram interaction was successfully destroyed.'
  end 

  private
    def set_instagram_interaction
      @instagram_interaction = InstagramInteraction.find(params[:id])
    end 

    def instagram_interaction_params
      params.require(:instagram_interaction).permit(:instagram_media_id, :instagram_user_id, :comment, :is_like) 
    end 
end
 
