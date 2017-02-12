class AddKeywordsToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :keywords, :string, array: true, default: []
  end
end
