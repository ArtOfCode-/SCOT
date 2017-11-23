class Dispatch::RequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access, except: [:new, :create]
  before_action :set_disaster
  before_action :set_request, except: [:index, :new, :create, :cad]

  def index
    @requests = @disaster.requests.paginate page: params[:page], per_page: 100
  end

  def new
    @request = @disaster.requests.new
  end

  def create
    @request = @disaster.requests.new request_params.merge(status: Dispatch::RequestStatus['New'], priority: Dispatch::Priority['New'])
    if @request.save
      flash[:success] = 'Saved request successfully.'
      redirect_to cad_request_path(@disaster, @request)
    else
      flash[:danger] = 'Failed to save your request.'
      render :new
    end
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @request }
    end
  end

  def edit; end

  def update
    if @request.update request_params
      flash[:success] = 'Saved request successfully.'
      redirect_to cad_request_path(@disaster, @request)
    else
      flash[:danger] = 'Failed to save your request.'
      render :new
    end
  end

  def destroy
    if @request.destroy
      flash[:success] = 'Removed request succesfully.'
      redirect_to cad_requests_path(@disaster)
    else
      flash[:danger] = 'Failed to remove request.'
      render :show
    end
  end

  def cad
    @requests = @disaster.requests.joins(:status).where.not(dispatch_requests: { status: [Dispatch::RequestStatus['Closed'],
                                                                                          Dispatch::RequestStatus['Safe']] })
                                  .joins(:priority).order('dispatch_priorities.index + dispatch_request_statuses.index ASC')
                                  .includes(:status, :priority, resource_uses: [:resource], resources: [:resource_type])
                                  .paginate(page: params[:page], per_page: 15)
    @crews = Dispatch::RescueCrew.dispatch_menu
  end

  def assign_crew
    @crew = Dispatch::RescueCrew.find params[:crew_id]
    @success = ApplicationRecord.status_transaction do
      @request.update!(status: Dispatch::RequestStatus['Dispatched'], rescue_crew: @crew)
      @crew.update!(status: Dispatch::CrewStatus['Assigned'])
    end
    render format: :json
  end

  def close
    success = @request.update status: Dispatch::RequestStatus['Closed']
    response = { success: success }
    response[:errors] = @request.errors.full_messages unless success
    render json: response
  end

  def add_resource
    @center = Dispatch::Resource.find params[:resource_id]
    @use = Dispatch::ResourceUse.new request: @request, resource: @center
    @success = @use.save
    render format: :json
  end

  def set_status
    status = Dispatch::RequestStatus.find params[:status_id]
    @success = @request.update status: status
    @request = @request.reload
    render format: :json
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end

  def set_request
    @request = Dispatch::Request.find params[:id]
  end

  def set_disaster
    @disaster = Disaster.find params[:disaster_id]
  end

  def request_params
    params.require(:dispatch_request).permit(:lat, :long, :name, :city, :country, :zip_code, :twitter, :phone, :email, :people_count,
                                             :medical_details, :extra_details, :street_address, :apt_no, :source)
  end
end
