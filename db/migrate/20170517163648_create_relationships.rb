class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.boolean :is_channel # determines whether to look for user or channel

      t.timestamps null: false
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, :is_channel
    add_index :relationships, [:follower_id, :followed_id, :is_channel], unique: true, :name => "index_relationships_on_following"
  end
end
