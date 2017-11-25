class Dispatch::RescueCrewsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access
  before_action :set_crew, except: [:index, :new, :create, :show]

  def index
    respond_to do |format|
      format.html do
        @crews = Dispatch::RescueCrew.all.includes(:status).paginate(page: params[:page], per_page: 50)
      end
      format.json do
        @crews = Dispatch::RescueCrew.where('capacity > ?', params[:min_capacity]).where(status: Dispatch::CrewStatus['Available'])
        @crews = @crews.where(medical: true) if params[:medical] == 'true'
        @count = @crews.count
        @crews = @crews.paginate(page: params[:page], per_page: 50)
        @more = @crews.count > 50 * (params[:page]&.to_i || 1)
      end
    end
  end

  def new
    @crew = Dispatch::RescueCrew.new
  end

  def create
    @crew = Dispatch::RescueCrew.new crew_params.merge(status: Dispatch::CrewStatus['Inactive'])
    if @crew.save
      flash[:success] = 'New crew created. Status must be set to Available before this crew appears for assignments.'
      redirect_to cad_rescue_crew_path(@crew)
    else
      flash[:danger] = 'Failed to save rescue crew.'
      render :new
    end
  end

  def show
    @crew = Dispatch::RescueCrew.includes(:status, :requests, requests: [:status, :priority]).where(id: params[:id]).first
  end

  def edit; end

  def update
    if @crew.update crew_params
      flash[:success] = 'Saved rescue crew.'
      redirect_to cad_rescue_crew_path(@crew)
    else
      flash[:danger] = 'Failed to save rescue crew.'
      render :edit
    end
  end

  def destroy
    if @crew.destroy
      flash[:success] = 'Removed rescue crew.'
    else
      flash[:danger] = 'Failed to remove rescue crew.'
    end
    redirect_to cad_rescue_crews_path
  end

  def set_status
    status = Dispatch::CrewStatus.find params[:status_id]
    if @crew.update status: status
      render json: { success: true, status: status }
    else
      render json: { success: false, errors: @crew.errors.full_messages }
    end
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end

  def set_crew
    @crew = Dispatch::RescueCrew.find params[:id]
  end

  def crew_params
    params.require(:dispatch_rescue_crew).permit(:contact_name, :contact_phone, :contact_email, :callsign, :medical, :capacity)
  end
end
