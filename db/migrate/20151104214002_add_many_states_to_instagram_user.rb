class AddManyStatesToInstagramUser < ActiveRecord::Migration
  def change
    remove_column :instagram_users, :state
    remove_column :instagram_users, :last_synced

    [
      :user_info, 
      :feed_info, 
      :interaction_info, 
      :followers_info, 
      :member_since, 
      :user_likes
    ].each do |k|
      add_column :instagram_users, "#{k}_state".to_sym, :string
      add_column :instagram_users, "#{k}_queued_at".to_sym, :datetime
      add_column :instagram_users, "#{k}_started_at".to_sym, :datetime
      add_column :instagram_users, "#{k}_finished_at".to_sym, :datetime
    end
  end
end