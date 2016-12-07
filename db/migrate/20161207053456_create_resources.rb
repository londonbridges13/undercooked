class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :title
      t.string :resource_url
      t.string :resource_type

      t.timestamps null: false
    end
  end
end
