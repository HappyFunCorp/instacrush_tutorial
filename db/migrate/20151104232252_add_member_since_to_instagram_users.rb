class AddMemberSinceToInstagramUsers < ActiveRecord::Migration
  def change
    add_column :instagram_users, :member_since, :datetime
  end
end
