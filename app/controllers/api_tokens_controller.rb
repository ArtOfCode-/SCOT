class APITokensController < ApplicationController
  before_action :authenticate_user!, except: [:fetch_token]
  before_action :require_developer, only: [:index]

  def index
    @tokens = APIToken.all.paginate(page: params[:page], per_page: 100)
  end
end
