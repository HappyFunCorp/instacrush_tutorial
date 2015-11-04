class CrushController < ApplicationController
  before_filter :require_instagram_user, except: [:show]
  before_filter :require_fresh_interactions, except: [:show]

  def index
    redirect_to Crush.find_for_user( current_user )
  end

  def show
    @crush = Crush.find_by_slug( params[:slug] )
  end

  def loading
    iu = current_user.instagram_user
    if iu.interaction_info_state == "synced"
      redirect_to Crush.find_for_user( current_user )
    end
  end
end
