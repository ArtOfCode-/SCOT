class TranslationsController < ApplicationController
  before_action :authenticate_user!, only: [:my_requests, :new, :create]
  before_action :set_translation, except: [:my_requests, :new, :create, :index]
  before_action :check_access, except: [:my_requests, :new, :create]

  def index
    @translations = Translation.where.not(status: [Translations::Status['Completed'], Translations::Status['Rejected']])
  end

  def my_requests
    @translations = Translation.where(requester: current_user)
  end

  def new
    @translation = Translation.new
  end

  def create
    @translation = Translation.create translation_params.merge(requester: current_user, status: Translations::Status['Pending Assessment'])
    if @translation.save
      flash[:success] = 'Added your translation request to the queue.'
      redirect_to my_translation_requests_path
    else
      flash[:danger] = 'Failed to queue your request.'
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @translation.update translation_params
      flash[:success] = 'Updated translation request.'
      redirect_back fallback_location: my_translation_requests_path
    else
      flash[:danger] = 'Failed to update translation request.'
      render :edit
    end
  end

  def update_status
    @status = Translations::Status.find params[:status_id]
    if params[:translate].present?
      @translation.update status: @status, assignee: current_user
      flash[:success] = "Status changed to #{@status.name}."
      redirect_to translate_translation_path(@translation)
    else
      @translation.update status: @status
      flash[:success] = "Status changed to #{@status.name}."
      redirect_back fallback_location: translations_path
    end
  end

  def translate; end

  def complete_translation
    if @translation.update final: params[:final]
      flash[:success] = 'Submitted completed translation.'
      redirect_to translations_path
    else
      flash[:danger] = 'Failed to submit completed translation.'
      render :translate
    end
  end

  private

  def check_access
    unless current_user.present? && @translation.present? && current_user == @translation.requester
      require_any :developer, :admin, :translator
    end
  end

  def translation_params
    params.require(:translation).permit(:content, :source_lang_id, :target_lang_id, :deliver_to, :due, :priority_id)
  end

  def set_translation
    @translation = Translation.find params[:id]
  end
end
