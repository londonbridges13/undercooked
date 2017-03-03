class AddTopicToTimer < ActiveRecord::Migration
  def change
    add_reference :timers, :topic, index: true, foreign_key: true
  end
end
