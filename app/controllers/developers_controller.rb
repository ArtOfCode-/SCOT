class DevelopersController < ApplicationController
  before_action :require_developer

  def change_users
    sign_in User.find(params[:id].to_i)
    redirect_back fallback_location: root_path
  end
end
