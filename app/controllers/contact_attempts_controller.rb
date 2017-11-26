class ContactAttemptsController < ApplicationController
  before_action :set_request
  before_action :set_attempt, except: [:new, :create]
  before_action :check_can_create_or_view
  before_action :check_can_modify, only: [:edit, :update, :destroy]

  def new
    @attempt = @request.contact_attempts.new
  end

  def create
    @attempt = @request.contact_attempts.new attempt_params.merge(user: current_user)
    if @attempt.save
      flash[:success] = 'Saved contact attempt!'
      redirect_to disaster_request_path(disaster_id: @request.disaster_id, num: @request.incident_number)
    else
      flash[:danger] = 'Failed to save contact attempt.'
      render :new
    end
  end

  def edit; end

  def update
    if @attempt.update attempt_params
      flash[:success] = 'Saved contact attempt!'
      redirect_to disaster_request_path(disaster_id: @request.disaster_id, num: @request.incident_number)
    else
      flash[:danger] = 'Failed to save contact attempt.'
      render :edit
    end
  end

  def destroy
    if @attempt.destroy
      flash[:success] = 'Removed contact attempt.'
    else
      flash[:danger] = 'Failed to remove contact attempt.'
    end
    redirect_to disaster_request_path(disaster_id: @request.disaster_id, num: @request.incident_number)
  end

  private

  def set_request
    @request = RescueRequest.find params[:request_id]
  end

  def set_attempt
    @attempt = ContactAttempt.find params[:id]
  end

  def check_can_create_or_view
    require_any :developer, :admin, :triage, :rescue, :medical
  end

  def check_can_modify
    unless current_user.present? && @attempt.user == current_user
      require_any :developer, :admin
    end
  end

  def attempt_params
    params.require(:contact_attempt).permit(:medium, :outcome, :details)
  end
end
