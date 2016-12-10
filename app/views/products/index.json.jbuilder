json.array!(@products) do |product|
  json.extract! product, :id, :title, :product_url
  json.url product_url(product, format: :json)
end
