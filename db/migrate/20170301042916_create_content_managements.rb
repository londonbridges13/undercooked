class CreateContentManagements < ActiveRecord::Migration
  def change
    create_table :content_managements do |t|
      t.string :last_new_article_grab_date

      t.timestamps null: false
    end
  end
end
