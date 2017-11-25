json.success @success
if @success
  json.crew @crew
  json.status do
    json.name @request.status.name
    json.description @request.status.description
    json.color @request.status.marker_type
    json.icon %w[exclamation-triangle exclamation-circle check info-circle][@request.status.index]
  end
  json.buttons render('buttons', request: @request, format: :html)
else
  json.errors @request.errors.full_messages
end
