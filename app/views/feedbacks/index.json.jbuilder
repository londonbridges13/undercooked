json.array!(@feedbacks) do |feedback|
  json.extract! feedback, :id, :message, :suggestion
  json.url feedback_url(feedback, format: :json)
end
