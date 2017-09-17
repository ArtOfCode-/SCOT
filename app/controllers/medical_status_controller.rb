class MedicalStatusController < ApplicationController
  before_action :check_access
  before_action :set_status, only: [:edit, :update]

  def index
    @medical_statuses = MedicalStatus.all
  end

  def update
    @medical_status.update(params[:medical_status].permit(%w[name description]))
    redirect_to action: :index
  end

  def edit; end

  def new; end

  def create
    MedicalStatus.create(params[:medical_status].permit(%w[name description]))
    redirect_to action: :index
  end

  private

  def check_access
    require_any :developer, :admin, :medical
  end

  def set_status
    @medical_status = MedicalStatus.find(params[:num])
  end
end
