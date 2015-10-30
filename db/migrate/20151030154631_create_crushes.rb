class CreateCrushes < ActiveRecord::Migration
  def change
    create_table :crushes do |t|
      t.references :user, index: true, foreign_key: true
      t.datetime :last_synced
      t.string :slug
      t.integer :instagram_user_id
      t.integer :crush_user_id
      t.integer :likes_count
      t.integer :comments_count

      t.timestamps null: false
    end
    add_index :crushes, :slug
  end
end
