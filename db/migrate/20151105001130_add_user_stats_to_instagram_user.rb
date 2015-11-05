class AddUserStatsToInstagramUser < ActiveRecord::Migration
  def change
    add_column :instagram_users, :recent_posts_count, :integer
    add_column :instagram_users, :recent_likes_count, :integer
    add_column :instagram_users, :recent_comments_count, :integer
  end
end
