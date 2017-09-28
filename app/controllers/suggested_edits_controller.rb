class SuggestedEditsController < ApplicationController
  before_action :set_request
  before_action :set_edit
  before_action :check_access

  def approve
    @edit.approve current_user
    flash[:success] = 'Approved.'
    redirect_to disaster_request_path(disaster_id: @request.disaster_id, num: @request.incident_number)
  end

  def reject
    @edit.reject current_user
    flash[:danger] = 'Rejected.'
    redirect_to disaster_request_path(disaster_id: @request.disaster_id, num: @request.incident_number)
  end

  private

  def set_request
    @request = RescueRequest.find params[:request_id]
  end

  def set_edit
    @edit = SuggestedEdit.find params[:id]
  end

  def check_access
    require_any :developer, :admin, :triage, :medical
  end
end
