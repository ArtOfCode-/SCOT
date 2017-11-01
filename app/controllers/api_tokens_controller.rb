class APITokensController < ApplicationController
  before_action :authenticate_user!, except: [:fetch_token]
  before_action :require_developer, only: [:index]
  before_action :set_key, except: [:index, :authorized]
  before_action :set_token, only: [:fetch_token, :revoke_user_app]
  before_action :check_user_access, only: [:revoke_user_app]
  before_action :check_app_access, only: [:revoke_app]

  def index
    @tokens = APIToken.all.paginate(page: params[:page], per_page: 100)
  end

  def authorized
    @keys = APIKey.where(id: current_user.api_tokens.map(&:api_key_id))
  end

  def auth_request; end

  def auth_grant
    available_scopes = ['write_access']
    valid_scopes = params[:scopes].split(';').select { |s| available_scopes.include? s }
    @token = @key.api_tokens.create user: current_user, token: SecureRandom.base64(30), code: SecureRandom.hex(4), scopes: valid_scopes
  end

  def auth_reject; end

  def fetch_token
    render json: { token: @key.api_tokens.find_by_code(params[:code]).token }
  end

  def revoke_user_app
    @key = APIKey.find params[:key_id]
    APIToken.where(user: current_user, api_key: @key).destroy_all
    flash[:success] = "Removed all your tokens for #{@key.name}."
    redirect_to my_apps_path
  end

  def revoke_app
    @key = APIKey.find params[:key_id]
    APIToken.where(api_key: @key).destroy_all
    flash[:success] = "Removed all tokens for your app #{@key.name}."
    redirect_to my_apps_path
  end

  private

  def set_key
    @key = APIKey.find_by key: params[:key]
  end

  def set_token
    @token = @key.api_tokens.find_by_code params[:code]
  end

  def check_user_access
    unless @token.user == current_user
      require_developer
    end
  end

  def check_app_access
    unless @key.user == current_user
      require_developer
    end
  end
end
