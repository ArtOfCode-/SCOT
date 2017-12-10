json.success @success
if @success
  json.crew @crew
  json.status do
    json.name @request.request_status.name
    json.description @request.request_status.description
    json.color @request.request_status.marker_type
    json.icon %w[exclamation-triangle exclamation-circle check info-circle][@request.request_status.index]
  end
  json.buttons render('buttons', request: @request, format: :html)
else
  json.errors @request.errors.full_messages
end
