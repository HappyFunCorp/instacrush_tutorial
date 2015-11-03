class AddStateToInstagramUser < ActiveRecord::Migration
  def change
    add_column :instagram_users, :state, :string
  end
end
