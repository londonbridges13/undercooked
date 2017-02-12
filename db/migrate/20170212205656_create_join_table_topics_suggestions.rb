class CreateJoinTableTopicsSuggestions < ActiveRecord::Migration
  def change
    create_join_table :topics, :suggestions do |t|
       t.index [:topic_id, :suggestion_id]
       t.index [:suggestion_id, :topic_id]
    end
  end
end
