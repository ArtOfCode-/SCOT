class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access, only: [:index, :new, :create, :show, :destroy]
  before_action :set_notification, only: [:show, :destroy, :read]

  def index
    @active = Notification.where('expires_at > ?', DateTime.now)
    @inactive = Notification.where('expires_at < ?', DateTime.now)
  end

  def new
    @notification = Notification.new
  end

  def create
    success = ApplicationRecord.status_transaction do
      @notification = Notification.create! notification_params.merge(creator: current_user)
      @notification.add_users params[:notification][:users]
    end
    if success
      flash[:success] = 'Your notification has been created.'
      redirect_to notifications_path
    else
      flash[:danger] = 'Failed to create your notification.'
      render :new
    end
  end

  def show
    @reads = ReadNotification.where(notification: @notification).includes(:user)
  end

  def destroy
    if @notification.destroy
      flash[:success] = 'Notification successfully removed.'
      redirect_to notifications_path
    else
      flash[:danger] = 'Failed to remove notification.'
      render :show
    end
  end

  def read
    @notification.read_notifications.create(user: current_user)
    render head: :no_content
  end

  private

  def notification_params
    params.require(:notification).permit(:title, :content, :expires_at)
  end

  def set_notification
    @notification = Notification.find params[:id]
  end

  def check_access
    require_any :developer, :admin
  end
end
