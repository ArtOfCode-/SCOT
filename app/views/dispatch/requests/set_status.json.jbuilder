json.success @success
if @success
  json.status do
    json.color @request.status.marker_type
    json.icon @request.status.icon
    json.merge! @request.status.as_json
  end
  json.buttons render('buttons', request: @request, format: :html)
else
  json.errors @request.errors.full_messages
end