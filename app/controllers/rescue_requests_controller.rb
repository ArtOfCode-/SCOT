class RescueRequestsController < ApplicationController
  def new
  end

  def create
    render plain: Disaster.find(params[:disaster_id]).rescue_requests.create(lat: params[:lat], long: params[:long]).id
  end

  def update_short
    RescueRequest.find(params[:person_id]).update(params.permit(RescueRequest.column_names).to_h)
  end

  def update_long
    RescueRequest.find(params[:person_id]).update(params.permit(RescueRequest.column_names).to_h)
    redirect_to root_path
  end
end
