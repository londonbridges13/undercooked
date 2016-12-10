class CreateJoinTableTagTopic < ActiveRecord::Migration
  def change
    create_join_table :tags, :topics do |t|
      t.index [:tag_id, :topic_id]
      t.index [:topic_id, :tag_id]
    end
  end
end
