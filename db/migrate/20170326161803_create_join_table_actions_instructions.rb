class CreateJoinTableActionsInstructions < ActiveRecord::Migration
  def change
    create_join_table :actions, :instructions do |t|
      t.index [:action_id, :instruction_id]
      t.index [:instruction_id, :action_id]
    end
  end
end
