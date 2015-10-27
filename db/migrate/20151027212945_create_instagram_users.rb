class CreateInstagramUsers < ActiveRecord::Migration
  def change
    create_table :instagram_users do |t|
      t.references :user, index: true, foreign_key: true
      t.datetime :last_synced
      t.string :username
      t.string :full_name
      t.string :profile_picture
      t.integer :media_count
      t.integer :followed_count
      t.integer :following_count

      t.timestamps null: false
    end
    add_index :instagram_users, :username
  end
end
