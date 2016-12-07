class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :article_url
      t.string :article_image_url
      t.text :desc
      t.string :resource_type
      t.timestamp :article_date
      t.boolean :publish_it

      t.timestamps null: false
    end
  end
end
