class AccessLogsController < ApplicationController
  before_action :check_access

  def on_resource
    @logs = AccessLog.includes(:user).where(resource_type: params[:resource_type], resource_id: params[:resource_id])
                     .paginate(page: params[:page], per_page: 100)
  end

  private

  def check_access
    require_any :developer, :admin
  end
end
