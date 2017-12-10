json.success @success
if @success
  json.status do
    json.color @request.request_status.marker_type
    json.icon @request.request_status.icon
    json.merge! @request.request_status.as_json
  end
  json.buttons render('buttons', request: @request, format: :html)
else
  json.errors @request.errors.full_messages
end
