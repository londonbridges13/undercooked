json.array!(@auto_publishings) do |auto_publishing|
  json.extract! auto_publishing, :id, :reasons
  json.url auto_publishing_url(auto_publishing, format: :json)
end
