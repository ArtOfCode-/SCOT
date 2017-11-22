class Dispatch::RescueCrewsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access

  def index
    respond_to do |format|
      format.html do
        @crews = Dispatch::RescueCrew.all.paginate(page: params[:page], per_page: 50)
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

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end
end
