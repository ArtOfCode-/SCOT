require 'csv'

class ApiController < ApplicationController
  def geojson
    features = Disaster.find(params[:disaster_id]).rescue_requests.map do |request|
      {
        type: 'Feature',
        geometry: {
          type: 'point',
          coordinates: [remove_empty(request.lat), remove_empty(request.long)]
        },
        properties: {
          name: remove_empty(request.name),
          city: remove_empty(request.city),
          status: remove_empty(request.request_status.name)
        }
      }
    end
    render json: {type: "FeatureCollection", features: features}
  end

  def csv
    output = CSV.generate do |csv|
      requests = Disaster.find(params[:disaster_id]).rescue_requests
      columns = %w[name city status lat long]
      csv << columns
      requests.map do |request|
        csv << columns.map { |i| i == 'status' ? request.request_status.name : request.send(i) }
      end
    end
    send_data output, type: 'text/csv', filename: 'export.csv', disposition: 'attachment'
  end

  private

  def remove_empty(text)
    text.to_s.empty? ? nil : text
  end
end
