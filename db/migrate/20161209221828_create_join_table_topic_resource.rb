class CreateJoinTableTopicResource < ActiveRecord::Migration
  def change
    create_join_table :topics, :resources do |t|
      t.index [:topic_id, :resource_id]
      t.index [:resource_id, :topic_id]
    end
  end
end
