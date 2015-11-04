class AddRemoteIdToInstagramUsers < ActiveRecord::Migration
  def change
    add_column :instagram_users, :remote_id, :string, nullable: false
  end
end
