require 'csv'

class ApiController < ApplicationController
  def geojson
    json = Disaster.find(params[:disaster_id]).rescue_requests.map do |request|
      {
        type: 'feature',
        geometry: {
          type: 'point',
          coordinates: [request.lat, request.long]
        },
        properties: {
          name: request.name,
          city: request.city,
          status: request.request_status.name
        }
      }
    end
    render json: json
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
end
