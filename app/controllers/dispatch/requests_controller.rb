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
    @request = @disaster.requests.new request_params
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
                                  .joins(:priority).order('SUM(dispatch_priorities.index, dispatch_request_statuses.index) ASC')
                                  .paginate(page: params[:page], per_page: 15)
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
end
