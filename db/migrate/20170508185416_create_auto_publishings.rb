class CreateAutoPublishings < ActiveRecord::Migration
  def change
    create_table :auto_publishings do |t|
      t.string :reasons

      t.timestamps null: false
    end
  end
end
