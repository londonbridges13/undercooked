json.array!(@resources) do |resource|
  json.extract! resource, :id, :title, :resource_url, :resource_type
  json.url resource_url(resource, format: :json)
end
