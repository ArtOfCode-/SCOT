class TranslationsController < ApplicationController
  before_action :authenticate_user!, only: [:my_requests, :new, :create, :final]
  before_action :set_translation, except: [:my_requests, :new, :create, :index, :my_assigns]
  before_action :check_access, except: [:my_requests, :new, :create, :final]

  def index
    @translations = Translation.includes(:source_lang, :target_lang, :status, :priority)
                               .where.not(status: [Translations::Status['Completed'], Translations::Status['Rejected']])
                               .order(created_at: :desc)
  end

  def my_requests
    @translations = Translation.includes(:source_lang, :target_lang, :status, :priority).where(requester: current_user)
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
      if current_user.has_role? :translator
        redirect_to translations_path
      else
        redirect_to my_translation_requests_path
      end
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
    if @translation.update final: params[:final], status: Translations::Status['Completed']
      flash[:success] = 'Submitted completed translation.'
      redirect_to translations_path
    else
      flash[:danger] = 'Failed to submit completed translation.'
      render :translate
    end
  end

  def final; end

  def my_assigns
    @translations = Translation.where(assignee: current_user).order(id: :desc)
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
