class CreateJoinTableTopicProduct < ActiveRecord::Migration
  def change
    create_join_table :topics, :products do |t|
      t.index [:topic_id, :product_id]
      t.index [:product_id, :topic_id]
    end
  end
end
