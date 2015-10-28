class CreateInstagramInteractions < ActiveRecord::Migration
  def change
    create_table :instagram_interactions do |t|
      t.references :instagram_media, index: true, foreign_key: true
      t.integer :instagram_user_id
      t.string :comment
      t.boolean :is_like

      t.timestamps null: false
    end
    add_index :instagram_interactions, :instagram_user_id
    add_index :instagram_interactions, :is_like
  end
end
