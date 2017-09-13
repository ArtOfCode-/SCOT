class ApiController < ApplicationController
  def geojson
    features = []
    Disaster.find(params[:disaster_id]).rescue_requests.map do |request|
      features.push({
        type: "feature",
        geometry: {
          type: "point",
          coordinates: [request.lat, request.long]
        },
        properties: {
          name: request.name,
          city: request.city,
          status: request.request_status.name
        }
      })
    end
    render json: features
  end

  def csv
  end
end
