class RescueRequestsController < ApplicationController
  before_action :set_disaster, except: [:index]
  before_action :set_request, except: [:index, :new, :create, :update, :disaster_index]
  before_action :set_loggable, only: [:show, :triage_status, :apply_triage_status, :mark_safe]
  before_action :check_access, only: [:show, :edit]
  before_action :check_triage, only: [:triage_status, :apply_triage_status]
  before_action :check_rescue, only: [:mark_safe]

  include AccessLogger

  def index
    @disasters = Disaster.all
  end

  def disaster_index
    status_ids = [RequestStatus.find_by(name: 'Rescued').id, RequestStatus.find_by(name: 'Closed').id]
    status_query = status_ids.map { |s| "request_status_id = #{s}" }.join(' OR ')
    @closed = @disaster.rescue_requests.where(status_query)
    @active = @disaster.rescue_requests.includes(:request_status).where.not(status_query)
    @counts = { closed: @closed.count, active: @active.count }

    @requests = @disaster.rescue_requests
    if params[:reporter].present?
      @requests = @requests.where("name LIKE '%#{params[:reporter]}%'")
    end
    if params[:city].present?
      @requests = @requests.where("city LIKE '%#{params[:city]}%'")
    end
    if params[:status_id].present? && !params[:status_id].all?(&:empty?)
      @requests = @requests.where(request_status_id: params[:status_id])
    end
    @requests = @requests.paginate(page: params[:page], per_page: 100)
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

    prev_values = @request.attributes.except %w[updated_at created_at id medical_status_id request_status_id]
    # Yes, there is a reason I did this in such a convoluted way.
    if @request.update(params.permit(params.keys).to_h.select { |k, _| cn.include? k })
      changes = prev_values.map {|k,v| "Changed #{k} from #{v} to #{@request.attributes[k]}" unless v == @request.attributes[k] }
      @request.case_notes.create(content: "#{current_user.username} committed the following changes:\n#{changes.join("\n")}")
      if params[:redirect]
        redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number)
      else
        render json: { status: 'success', request: @request.as_json, location: redirect }
      end
    else
      render json: { status: 'failed' }, status: 500
    end
  end

  def show; end

  def edit; end

  def triage_status
    @statuses = RequestStatus.all
  end

  def apply_triage_status
    if @request.update(request_status_id: params[:status_id])
      flash[:success] = "Status updated."
    else
      flash[:danger] = "Failed to update status."
    end
    redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number)
  end

  def mark_safe
    safe = RequestStatus.find_by name: 'Rescued'
    if @request.update request_status: safe
      flash[:success] = 'Marked as safe.'
    else
      flash[:danger] = "Couldn't mark as safe."
    end
    redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number)
  end

  private

  def set_disaster
    @disaster = Disaster.find params[:disaster_id]
  end

  def set_request
    @request = @disaster.rescue_requests.find_by incident_number: params[:num]
  end

  def set_loggable
    @loggable = @request
  end

  def check_access
    require_any :developer, :admin, :triage, :rescue
  end

  def check_triage
    require_any :developer, :admin, :triage
  end

  def check_rescue
    require_any :developer, :admin, :rescue
  end

  protected

  def log_actions
    [:show, :triage_status, :apply_triage_status, :mark_safe]
  end
end
