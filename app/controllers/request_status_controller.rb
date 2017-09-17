class RequestStatusController < ApplicationController
  before_action :check_access
  before_action :set_status, only: [:edit, :update]

  def index
    @request_statuses = RequestStatus.all
  end

  def update
    @request_status.update(params[:request_status].permit(%w[name description]))
    redirect_to action: :index
  end

  def edit; end

  def new; end

  def create
    RequestStatus.create(params[:request_status].permit(%w[name description]))
    redirect_to action: :index
  end

  private

  def check_access
    require_any :developer, :admin
  end

  def set_status
    @request_status = RequestStatus.find(params[:num])
  end
end
