class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access, except: [:add_lead]
  before_action :check_admin, only: [:add_lead]

  def index
    @users = if params[:filter].present?
               User.where("username LIKE '%#{params[:filter]}%'")
             else
               User.all
             end.order(id: :desc).paginate page: params[:page], per_page: 50
    @role_names = Role.global_defaults
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

  def add_lead
    @user = User.find params[:user_id]
    @channel = Channel.find params[:channel_id]
    if params[:mode] == 'add'
      @user.add_role :channel_lead, @channel
      flash[:success] = "Added #{@user.username} as a channel lead of #{@channel.name}."
    else
      @user.remove_role :channel_lead, @channel
      flash[:warning] = "Removed #{@user.username} as a channel lead of #{@channel.name}."
    end
    redirect_to admin_roles_path
  end

  private

  def check_access
    require_any :developer, :admin, channel_lead: :any
  end

  def check_admin
    require_any :developer, :admin
  end
end
