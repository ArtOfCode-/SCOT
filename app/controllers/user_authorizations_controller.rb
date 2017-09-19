class UserAuthorizationsController < ApplicationController
  before_action :check_access

  def create
    @user_auth = UserAuthorization.new auth_params
    @user_auth.valid_on = params[:user_authorization][:valid_on].join(',')
    @user_auth.granted_by = current_user
    if @user_auth.save
      flash[:success] = "Authorization granted to #{@user_auth.user.username}."
    else
      flash[:danger] = "Couldn't save authorization."
    end

    redirect_back fallback_location: root_path
  end

  def destroy
    @user_auth = UserAuthorization.find params[:id]
    if @user_auth.destroy
      flash[:success] = 'Removed authorization.'
    else
      flash[:danger] = "Couldn't remove authorization."
    end

    redirect_back fallback_location: root_path
  end

  private

  def check_access
    require_any :developer, :admin
  end

  def auth_params
    params.require(:user_authorization).permit(:user_id, :resource_type, :resource_id, :expires_at, :valid_on, :reason)
  end
end
