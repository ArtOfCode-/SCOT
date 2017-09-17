class MedicalStatusController < ApplicationController
  before_action :check_access

  def index
    @medical_statuses = MedicalStatus.all
  end

  def update
    MedicalStatus.find(params[:medical_status][:id]).update(params[:medical_status].permit(%w[name description]))
    redirect_to action: :index
  end

  def edit
    @medical_status = MedicalStatus.find(params[:num])
  end

  def new; end

  def create
    MedicalStatus.create(params[:medical_status].permit(%w[name description]))
    redirect_to action: :index
  end

  def check_access
    require_any :developer, :admin, :medical
  end
end
