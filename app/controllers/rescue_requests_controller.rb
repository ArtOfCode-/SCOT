class RescueRequestsController < ApplicationController
  before_action :set_disaster, except: [:index]

  def index
    @requests = RescueRequest.all
    @disasters = Disaster.all
  end

  def new; end

  def create
    @request = @disaster.rescue_requests.new(lat: params[:lat], long: params[:long])
    if @request.save
      render json: { status: 'success', id: @request.id }
    else
      render json: { status: 'failed' }, status: 500
    end
  end

  def update
    @request = RescueRequest.find params[:request_id]
    redirect = params[:com_redir].present? ? disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number) : nil
    cn = RescueRequest.column_names - %w[id incident_number key created_at updated_at disaster_id]

    # Yes, there is a reason I did this in such a convoluted way.
    if @request.update(params.permit(params.keys).to_h.select { |k, _| cn.include? k })
      render json: { status: 'success', request: @request.as_json, location: redirect }
    else
      render json: { status: 'failed' }, status: 500
    end
  end

  private

  def set_disaster
    @disaster = Disaster.find params[:disaster_id]
  end
end
