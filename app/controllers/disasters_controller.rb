class DisastersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @disasters = Disaster.active.paginate(page: params[:page], per_page: 25)
  end
end
