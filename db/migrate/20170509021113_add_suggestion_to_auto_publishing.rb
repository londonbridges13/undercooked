class AddSuggestionToAutoPublishing < ActiveRecord::Migration
  def change
    add_reference :auto_publishings, :suggestion, index: true, foreign_key: true
  end
end
