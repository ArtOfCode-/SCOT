class Dispatch::ResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access
  before_action :set_resource, except: [:index, :rest_stops, :new, :create]

  def index
    respond_to do |format|
      format.html do
        @resources = Dispatch::Resource.all.paginate(page: params[:page], per_page: 50)
      end
      format.json do
        request = Dispatch::Request.find params[:request_id]
        @resources = Dispatch::Resource.all.includes(:resource_type).where.not(resource_type: Dispatch::ResourceType['Rest Stop'])
                                       .order("SQRT(POW(`long` - (#{request.long}), 2) + POW(`lat` - (#{request.lat}), 2))")
        @count = @resources.count
        @resources = @resources.paginate(page: params[:page], per_page: 50)
        @more = @resources.count > 50 * (params[:page]&.to_i || 1)
      end
    end
  end

  def rest_stops
    request = Dispatch::Request.find params[:request_id]
    @resources = Dispatch::Resource.all.includes(:resource_type).where(resource_type: Dispatch::ResourceType['Rest Stop'])
                                   .order("SQRT(POW(`long` - (#{request.long}), 2) + POW(`lat` - (#{request.lat}), 2))")
    @count = @resources.count
    @resources = @resources.paginate(page: params[:page], per_page: 50)
    @more = @resources.count > 50 * (params[:page]&.to_i || 1)
  end

  def new
    @resource = Dispatch::Resource.new
  end

  def create
    @resource = Dispatch::Resource.new resource_params
    if @resource.save
      flash[:success] = 'Saved new resource.'
      redirect_to cad_resource_path(@resource)
    else
      flash[:danger] = 'Failed to save new resource.'
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @resource.update resource_params
      flash[:success] = 'Updated resource.'
      redirect_to cad_resource_path(@resource)
    else
      flash[:danger] = 'Failed to update resource.'
      render :edit
    end
  end

  def destroy
    if @resource.destroy
      flash[:success] = 'Removed resource.'
    else
      flash[:danger] = 'Failed to remove resource.'
    end
    redirect_to cad_resources_path
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end

  def set_resource
    @resource = Dispatch::Resource.find params[:id]
  end
end
