class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = if params[:filter].present?
               User.where("username LIKE '%#{params[:filter]}%'")
             else
               User.all
             end.order(id: :desc).paginate page: params[:page], per_page: 50
    @role_names = (Role.all.map { |x| x.name.to_sym } + Role.global_defaults).uniq
  end

  def add_role
    @user = User.find params[:user_id]
    @role_name = params[:role_name]
    if Role.can_grant? current_user, @role_name.to_sym
      @user.add_role @role_name
      flash[:success] = "Applied #{@role_name} role to #{@user.username}."
    else
      flash[:danger] = "You don't have permission to grant that role."
    end
    redirect_to admin_roles_path
  end

  def remove_role
    @user = User.find params[:user_id]
    @role_name = params[:role_name]
    if Role.can_grant? current_user, @role_name.to_sym
      @user.remove_role @role_name
      flash[:warning] = "Removed #{@role_name} role from #{@user.username}."
    else
      flash[:danger] = "You don't have permission to revoke that role."
    end
    redirect_to admin_roles_path
  end
end
