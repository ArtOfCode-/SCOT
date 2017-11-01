class APIKeysController < ApplicationController
  before_action :authenticate_user!
  before_action :require_developer, only: [:index]
  before_action :set_key, only: [:show, :edit, :update, :destroy]

  def index
    @keys = APIKey.all.paginate(page: params[:page], per_page: 100)
  end

  def directory
    @keys = APIKey.all.paginate(page: params[:page], per_page: 30)
  end

  def new
    @key = APIKey.new
  end

  def create
    @key = APIKey.new key_params.merge({ user: current_user, key: SecureRandom.base64(30) })
    if @key.save
      flash[:success] = 'Successfully created your API key.'
      redirect_to api_key_path(@key)
    else
      flash[:danger] = 'Failed to save your key - check for errors and try again.'
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @key.update key_params
      flash[:success] = 'Successfully updated your key.'
      redirect_to api_key_path(@key)
    else
      flash[:danger] = 'Failed to save your key - check for errors and try again.'
      render :edit
    end
  end

  def destroy
    if @key.destroy
      flash[:success] = 'Removed your API key.'
      redirect_to app_directory_path
    else
      flash[:danger] = 'Failed to remove your key.'
      redirect_to api_key_path(@key)
    end
  end

  private

  def key_params
    params.require(:api_key).permit(:name, :description)
  end

  def set_key
    @key = APIKey.find params[:id]
  end
end
