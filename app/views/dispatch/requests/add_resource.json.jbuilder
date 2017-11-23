json.success @success
if @success
  json.resource do
    json.merge! @center.as_json
    json.resource_type @center.resource_type
  end
  json.buttons render('buttons', request: @request, format: :html)
else
  json.errors @use.errors.full_messages
end