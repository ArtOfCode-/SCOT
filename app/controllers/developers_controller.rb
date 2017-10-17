class DevelopersController < ApplicationController
  before_action :require_developer, except: [:change_back, :verify_elevation]
  before_action :check_impersonating, only: [:change_back, :verify_elevation]

  def change_users
    dev_id = current_user.id
    @user = User.find params[:id]
    sign_in @user
    session[:impersonator_id] = dev_id
    flash[:success] = "You are now impersonating #{@user.username}."
    redirect_to root_path
  end

  def change_back
    @impersonator = User.find session[:impersonator_id]
  end

  def verify_elevation
    impersonator = User.find session[:impersonator_id]
    if impersonator&.valid_password? params[:password]
      session.delete :impersonator_id
      sign_in impersonator
      redirect_to root_path
    else
      flash[:danger] = 'Incorrect password.'
      render :change_back
    end
  end

  private

  def check_impersonating
    unless session[:impersonator_id].present?
      require_developer
    end
  end
end
