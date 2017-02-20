class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :message
      t.string :suggestion

      t.timestamps null: false
    end
  end
end
