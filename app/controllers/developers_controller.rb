class DevelopersController < ApplicationController
  before_action :check_dev

  def change_users
    sign_in User.find(params[:id].to_i)
    redirect_back fallback_location: root_path
  end

  private

  def check_dev
    require_any :developer
  end
end
