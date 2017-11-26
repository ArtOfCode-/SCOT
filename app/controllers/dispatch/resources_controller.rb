class Dispatch::ResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access

  def index
    respond_to do |format|
      format.html do
        @resources = Dispatch::Resource.all.paginate(page: params[:page], per_page: 50)
      end
      format.json do
        request = Dispatch::Request.find params[:request_id]
        @resources = Dispatch::Resource.all.includes(:resource_type)
                                       .order("SQRT(POW(`long` - (#{request.long}), 2) + POW(`lat` - (#{request.lat}), 2))")
        @count = @resources.count
        @crews = @resources.paginate(page: params[:page], per_page: 50)
        @more = @resources.count > 50 * (params[:page]&.to_i || 1)
      end
    end
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end
end
