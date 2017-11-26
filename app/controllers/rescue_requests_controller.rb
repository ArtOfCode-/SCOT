class RescueRequestsController < ApplicationController
  before_action :set_disaster, except: [:index]
  before_action :set_request, except: [:index, :new, :create, :disaster_index, :cad]
  before_action :set_loggable, only: [:show, :triage_status, :apply_triage_status, :mark_safe, :update]
  before_action :check_access, only: [:show, :edit, :update, :assignee, :apply_assignee]
  before_action :check_triage, only: [:triage_status, :apply_triage_status]
  before_action :check_rescue, only: [:mark_safe]
  before_action :check_medical, only: [:apply_medical_triage_status]
  before_action :check_admin, only: [:authorizations]

  include AccessLogger

  PROHIBITED_FIELDS = %w[id incident_number key created_at updated_at disaster_id assignee_id].freeze

  def index
    @disasters = Disaster.all
  end

  def disaster_index
    status_ids = [RequestStatus.find_by(name: 'Rescued').id, RequestStatus.find_by(name: 'Closed').id]
    status_query = status_ids.map { |s| "request_status_id = #{s.to_i}" }.join(' OR ')
    @closed = @disaster.rescue_requests.where(status_query)
    @active = @disaster.rescue_requests.includes(:request_status).where.not(status_query)
    @counts = { closed: @closed.count, active: @active.count }

    @requests = @disaster.rescue_requests
    if params[:reporter].present?
      @requests = @requests.where('name LIKE ?', "%#{params[:reporter]}%")
    end
    if params[:city].present?
      @requests = @requests.where("city LIKE '%#{params[:city]}%'")
    end
    if params[:status_id].present? && !params[:status_id].all?(&:empty?)
      @requests = @requests.where(request_status_id: params[:status_id])
    end
    @requests = @requests.paginate(page: params[:page], per_page: 100)
  end

  def new
    @rescue_request = RescueRequest.new
  end

  def create
    medical_conditions = params.permit(MedicalCondition.all.map { |m| "conditions_#{m.id}".to_sym }).to_hash
                               .map { |key| MedicalCondition.find(key.to_s.split('_').last.to_i) }
    @request = @disaster.rescue_requests.new request_params.merge(key: SecureRandom.hex(32), status: RequestStatus['New'], priority: RequestPriority['New'], medical_conditions: {medical_conditions: medical_conditions})
    if @request.save
      flash[:success] = 'Saved request successfully.'
      redirect_to disaster_request_path(disaster_id: @disaster.id, num: @request.incident_number, key: params[:key])
    else
      flash[:danger] = 'Failed to save your request.'
      render :new
    end
  end

  def show
    @duplicates = RescueRequest.where(dupe_of: @request.id)
    @duplicate_of = RescueRequest.find(@request.dupe_of) if @request.dupe_of.to_i > 0
    @timeline = (@request.case_notes + @request.contact_attempts + @request.suggested_edits).sort_by(&:created_at).reverse

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @request }
    end
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

  def suggest_edit
    @suggesting = true
    render :edit
  end

  def suggest_edit_submit
    new_values = params.permit(RescueRequest.column_names - PROHIBITED_FIELDS).to_h.map do |field, value|
      value.to_s == @request[field].to_s ? nil : [field, value]
    end.reject(&:nil?).to_h
    old_values = @request.attributes.except PROHIBITED_FIELDS

    @edit = current_user.suggested_edits.new(resource: @request, comment: params[:suggested_edit_comment],
                                             new_values: new_values, old_values: old_values)
    if current_user.present? && current_user.has_any_role?(:developer, :admin, :triage, :medical) && @edit.save
      @edit.approve current_user
      @request.update new_values
      flash[:info] = 'Your edits have been applied.'
      redirect_to action: :show
    elsif @edit.save
      flash[:info] = 'Your suggested edit was submitted.'
      redirect_to action: :show
    else
      flash[:warning] = 'Failed to save suggested edit.'
      redirect_to action: :suggest_edit
    end
  end

  # I have a feeling that this should go over to the dispatch controller

  def cad
    @rescue_requests = @disaster.rescue_requests.joins(:request_status).where.not(rescue_requests: { status: [RequestStatus['Closed'],
                                                                                          RequestStatus['Safe']] })
                                  .joins(:request_priority).order('request_priorities.index + rescue_request_statuses.index ASC')
                                  .paginate(page: params[:page], per_page: 15)
    @crews = Dispatch::RescueCrew.dispatch_menu
  end

  def cad_index
    @disasters = Disaster.all
  end

  def assign_crew
    @crew = Dispatch::RescueCrew.find params[:crew_id]
    @success = ApplicationRecord.status_transaction do
      @request.update!(status: RequestStatus['Dispatched'], rescue_crew: @crew)
      @crew.update!(status: Dispatch::CrewStatus['Assigned'])
    end
    render format: :json
  end

  def close
    success = @request.update status: RequestStatus['Closed']
    response = { success: success }
    response[:errors] = @request.errors.full_messages unless success
    render json: response
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

  def request_params
    params.require(:rescue_request).permit(:lat, :long, :name, :city, :country, :zip_code, :twitter, :phone, :email, :people_count,
                                             :medical_details, :extra_details, :street_address, :apt_no, :source)
  end

  protected

  def log_actions
    [:show, :edit, :triage_status, :apply_triage_status, :mark_safe]
  end
end
