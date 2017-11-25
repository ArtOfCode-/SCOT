class Dispatch::ContactAttemptsController < ApplicationController
  before_action :check_access
  before_action :set_request
  before_action :set_attempt, except: [:new, :create]

  def new
    @attempt = @request.contact_attempts.new
  end

  def create
    @attempt = @request.contact_attempts.new attempt_params.merge(user: current_user)
    if @attempt.save
      flash[:success] = 'Saved contact attempt.'
      redirect_to cad_request_path(@request.disaster, @request)
    else
      flash[:danger] = 'Failed to save contact attempt.'
      render :new
    end
  end

  def edit; end

  def update
    if @attempt.update attempt_params
      flash[:success] = 'Saved contact attempt.'
      redirect_to cad_request_path(@request.disaster, @request)
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
    redirect_to cad_request_path(@request.disaster, @request)
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end

  def set_request
    @request = Dispatch::Request.find params[:rid]
  end

  def set_attempt
    @attempt = Dispatch::ContactAttempt.find params[:id]
  end

  def attempt_params
    params.require(:dispatch_contact_attempt).permit(:medium, :outcome, :details)
  end
end
