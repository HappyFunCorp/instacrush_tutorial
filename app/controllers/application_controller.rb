class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate

  def authenticate
    unless ENV['HTTP_AUTH_USERNAME'].blank? or ENV['HTTP_AUTH_PASSWORD'].blank?
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['HTTP_AUTH_USERNAME'] && password == ENV['HTTP_AUTH_PASSWORD']
      end
    end
  end

  def require_instagram_user
    if current_user.nil? || current_user.instagram.nil?
      store_location_for( :user, request.path )
      redirect_to user_omniauth_authorize_path( :instagram )
      return false
    end
  end

  def require_fresh_interactions
    if current_user.find_instagram_user.sync_interaction_info_needed?
      current_user.find_instagram_user.sync_interaction_info

      flash[:notice] = "We're talking with instagram right now"
      if request.path != loading_crush_index_path
        redirect_to loading_crush_index_path
        return false
      end
    end
  end
end
