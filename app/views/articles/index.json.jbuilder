json.array!(@articles) do |article|
  json.extract! article, :id, :title, :article_url, :article_image_url, :desc, :resource_type, :article_date, :publish_it
  json.url article_url(article, format: :json)
end
