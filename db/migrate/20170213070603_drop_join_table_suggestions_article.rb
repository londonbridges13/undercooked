class DropJoinTableSuggestionsArticle < ActiveRecord::Migration
  def change
    drop_join_table :articles, :suggestions 
  end
end
