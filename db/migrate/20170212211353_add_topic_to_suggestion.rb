class AddTopicToSuggestion < ActiveRecord::Migration
  def change
    add_reference :suggestions, :topic, index: true
  end
end
