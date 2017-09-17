class RequestStatusController < ApplicationController
  def index
    @request_statuses = RequestStatus.all
  end

  def update
    RequestStatus.find(params[:request_status][:id]).update(params[:request_status].permit(%w[name description]))
    redirect_to action: :index
  end

  def edit
    @request_status = RequestStatus.find(params[:num])
  end

  def new; end

  def create
    RequestStatus.create(params[:request_status].permit(%w[name description]))
    redirect_to action: :index
  end
end
