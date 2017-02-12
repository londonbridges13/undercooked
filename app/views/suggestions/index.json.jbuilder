json.array!(@suggestions) do |suggestion|
  json.extract! suggestion, :id, :rejected, :reason, :evidence
  json.url suggestion_url(suggestion, format: :json)
end
