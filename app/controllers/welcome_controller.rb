class WelcomeController < ApplicationController
  def landing
    if current_user.present?
      redirect_to crush_index_path
    end
  end

  def calculating
  end

  def show_crush
  end

  def top_users
  end

  def top_posts
  end
end
