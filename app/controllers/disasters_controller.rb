class DisastersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:index]

  def index
    @disasters = Disaster.active.paginate(page: params[:page], per_page: 25)
  end

  def new
    @disaster = Disaster.new
  end

  def create
    @disaster = Disaster.create disaster_params
    @disaster.active = true
    if @disaster.save
      flash[:success] = "Success - disaster response functionality is now available for #{@disaster.name}."
      redirect_to disasters_path
    else
      flash[:danger] = 'Failed to save record - please try again and contact support if the issue persists.'
      render :new
    end
  end

  private

  def disaster_params
    params.require(:disaster).permit(:name, :description, :active)
  end
end
