class DeleteJoinTableTopicsSuggestions < ActiveRecord::Migration
  def change
  drop_join_table :suggestions, :topics 
  end
end
