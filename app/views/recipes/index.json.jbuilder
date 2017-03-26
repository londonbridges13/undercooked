json.array!(@recipes) do |recipe|
  json.extract! recipe, :id, :title, :description, :author, :serving_size, :prep_time, :cooktime, :total_time
  json.url recipe_url(recipe, format: :json)
end
