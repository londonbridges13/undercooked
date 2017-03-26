json.array!(@ingredients) do |ingredient|
  json.extract! ingredient, :id, :title
  json.url ingredient_url(ingredient, format: :json)
end
