class RescueRequestsController < ApplicationController
  before_action :set_disaster, except: [:index]
  before_action :set_request, except: [:index, :new, :create, :disaster_index]
  before_action :set_loggable, only: [:show, :triage_status, :apply_triage_status, :mark_safe]
  before_action :check_access, only: [:show, :edit, :update]
  before_action :check_triage, only: [:triage_status, :apply_triage_status]
  before_action :check_rescue, only: [:mark_safe]
  before_action :check_medical, only: [:apply_medical_triage_status]
  before_action :check_admin, only: [:authorizations]

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
    @request = @disaster.rescue_requests.new(lat: params[:lat], long: params[:long], key: SecureRandom.hex(32))
    if @request.save
      render json: { status: 'success', id: @request.id, key: @request.key }
    else
      render json: { status: 'failed' }, status: 500
    end
  end

  def update
    @request = RescueRequest.find params[:request_id]
    redirect = params[:com_redir].present? ? disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number, key: params[:key]) : nil
    cn = RescueRequest.column_names - %w[id incident_number key created_at updated_at disaster_id chart_code]
    cn.push 'chart_code' if current_user.present? && current_user.has_any_role?(:medical, :developer)

    prev_values = @request.attributes.except %w[updated_at created_at id medical_status_id request_status_id disaster_id]
    # Yes, there is a reason I did this in such a convoluted way.
    if @request.update(params.permit(params.keys).to_h.select { |k, _| cn.include? k })
      changes = prev_values.map { |k, v| "Changed #{k} from #{v} to #{@request.attributes[k]}" unless v.to_s == @request.attributes[k].to_s }
                           .reject { |i| i.nil? || i.empty? }
      @request.case_notes.create(content: "#{current_user.username} committed the following changes:\n#{changes.join("\n")}") if current_user.present?
      if params[:redirect]
        redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number)
      else
        render json: { status: 'success', request: @request.as_json, location: redirect }
      end
    else
      render json: { status: 'failed' }, status: 500
    end
  end

  def show
    @duplicates = RescueRequest.where(dupe_of: @request.id)
    @duplicate_of = RescueRequest.find(@request.dupe_of) if @request.dupe_of.to_i > 0
    @timeline = (@request.case_notes + @request.contact_attempts).sort_by(&:created_at).reverse
  end

  def edit; end

  def triage_status
    @statuses = RequestStatus.all
    @medical_statuses = MedicalStatus.all
  end

  def apply_triage_status
    previous_status = @request.request_status.name
    if @request.update(request_status_id: params[:status_id])
      @request.case_notes.create(content: "#{current_user.username} changed the status from #{previous_status} to #{@request.request_status.name}.")
      flash[:success] = 'Status updated.'
    else
      flash[:danger] = 'Failed to update status.'
    end
    redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number)
  end

  def apply_medical_triage_status
    prev_status = @request.medical_status&.name || '(no status)'
    if @request.update(medical_status_id: params[:status_id])
      @request.case_notes.create(user_id: nil, medical: true,
                                 content: "#{current_user.username} changed medical status from #{prev_status} to #{@request.medical_status.name}")
      flash[:success] = 'Status updated.'
    else
      flash[:danger] = 'Failed to update status.'
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

  def authorizations
    @authorizations = UserAuthorization.where(resource: @request).where('expires_at > ?', DateTime.now)
    @user_authorization = UserAuthorization.new
  end

  def assignee; end

  def apply_assignee
    if @request.update(assignee_id: params[:aid])
      flash[:success] = 'Updated assignee.'
    else
      flash[:danger] = 'Failed to update assignee.'
    end
    redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number)
  end

  private

  def set_disaster
    @disaster = Disaster.find params[:disaster_id]
  end

  def set_request
    if params[:num].present?
      @request = @disaster.rescue_requests.find_by incident_number: params[:num]
    elsif params[:request_id].present?
      @request = RescueRequest.find params[:request_id]
    end
  end

  def set_loggable
    @loggable = @request
  end

  def check_access
    if params[:key].present? && @request.present? && params[:key] == @request.key
      Rails.logger.info "Granted access to RescueRequest##{@request.id} based on key #{params[:key]}."
      return
    end

    if current_user.present? && current_user.authorized_to?(action_name.to_sym, @request)
      authorization = current_user.authorization_for(action_name.to_sym, @request).first
      Rails.logger.info "Granted access to RescueRequest##{@request.id} based on UserAuthorization##{authorization.id}."
      Rails.logger.info "Authorization for #{current_user.id} on #{authorization.valid_on} granted by #{authorization.granted_by.id}."
      return
    end

    require_any :developer, :admin, :triage, :rescue, :medical
  end

  def check_triage
    require_any :developer, :admin, :triage
  end

  def check_rescue
    require_any :developer, :admin, :rescue
  end

  def check_medical
    require_any :developer, :medical
  end

  def check_admin
    require_any :developer, :admin
  end

  protected

  def log_actions
    [:show, :edit, :triage_status, :apply_triage_status, :mark_safe]
  end
end
