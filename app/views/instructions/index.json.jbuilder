json.array!(@instructions) do |instruction|
  json.extract! instruction, :id, :instruction
  json.url instruction_url(instruction, format: :json)
end
