class CreateInstagramRelationships < ActiveRecord::Migration
  def change
    create_table :instagram_relationships do |t|
      t.integer :instagram_user_id
      t.integer :subject_user_id
      t.boolean :followed_by
      t.boolean :follows
      t.boolean :interacted

      t.timestamps null: false
    end
    add_index :instagram_relationships, :instagram_user_id
    add_index :instagram_relationships, :subject_user_id
  end
end
