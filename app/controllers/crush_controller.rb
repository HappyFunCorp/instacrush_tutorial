class CrushController < ApplicationController
  before_filter :require_instagram_user
  before_filter :require_fresh_user

  def index
    redirect_to Crush.find_for_user( current_user )
  end

  def show
    @crush = Crush.find( params[:id] )
  end

  def loading
  end
end
