class CreateInstagramMedia < ActiveRecord::Migration
  def change
    create_table :instagram_media do |t|
      t.references :instagram_user, index: true, foreign_key: true
      t.string :media_id
      t.string :media_type
      t.integer :comments_count
      t.integer :likes_count
      t.string :link
      t.string :thumbnail_url
      t.string :standard_url

      t.timestamps null: false
    end
  end
end
