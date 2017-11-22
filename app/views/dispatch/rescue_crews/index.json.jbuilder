json.results do
  json.array! @crews do |c|
    json.merge! c.as_json
    json.text "#{c.callsign} (#{c.medical? ? 'medical, ' : ''}capacity #{c.capacity})"
  end
end

json.pagination do
  json.more @more
end