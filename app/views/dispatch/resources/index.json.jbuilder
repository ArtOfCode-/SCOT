json.results do
  json.array! @resources do |r|
    json.merge! r.as_json
    json.text "#{r.name} (#{r.resource_type.name})"
  end
end

json.pagination do
  json.more @more
end
