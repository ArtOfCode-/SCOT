class TranslationsController < ApplicationController
  before_action :set_translation, except: [:my_requests, :new, :create, :index, :my_assigns, :dedupe_remote_data]
  before_action :check_access, except: [:my_requests, :new, :create, :final, :edit, :update]
  before_action :check_edit, only: [:edit, :update]
  before_action :redirect_duplicates, except: [:my_requests, :new, :create, :index, :my_assigns, :show, :dedupe_remote_data]

  def index
    @translations = Translation.includes(:source_lang, :target_lang, :priority).joins(:status)
                               .where.not(translation_statuses: { name: %w[Completed Rejected] })
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
    status = params[:completed].present? ? Translations::Status['Completed'] : Translations::Status['Pending Review']
    if @translation.update final: params[:final], status: status
      flash[:success] = params[:completed].present? ? 'Saved completed translation.' : 'Saved and sent for review.'
      redirect_to translations_path
    else
      flash[:danger] = 'Failed to save completed translation.'
      render :translate
    end
  end

  def final; end

  def my_assigns
    @translations = Translation.where(assignee: current_user).order(id: :desc)
  end

  def deduplicate; end

  def submit_dedupe
    @translation.make_duplicate params[:dupe_id]
    flash[:success] = "Marked ##{@translation.id} as a duplicate of ##{params[:dupe_id]}."
    redirect_to translation_path(id: params[:dupe_id])
  end

  def dedupe_remote_data
    results = Translation.where('id LIKE ?', "#{params[:q]}%")
    render json: { results: results.map { |i| { id: i.id, text: "##{i.id}", content: i.content.present? ? i.content : i.final } },
                   pagination: { more: false } }
  end

  def notes; end

  def submit_notes
    changes = { notes: params[:notes] }
    changes[:status] = Translations::Status['On Hold'] if params[:hold_request].present?
    @translation.update(**changes)
    flash[:success] = "Added your notes."
    redirect_to translation_path(@translation)
  end

  private

  def check_access
    unless current_user.present? && @translation.present? && current_user == @translation.requester
      require_any :developer, :admin, :translator
    end
  end

  def check_edit
    unless current_user.present? && @translation.present? && current_user == @translation.requester
      require_any :developer, :admin, :translator, :broadcast, :miner
    end
  end

  def translation_params
    params.require(:translation).permit(:content, :final, :source_lang_id, :target_lang_id, :deliver_to, :due, :priority_id)
  end

  def set_translation
    @translation = Translation.find params[:id]
  end

  def redirect_duplicates
    if @translation.present? && @translation.duplicate_of.present?
      flash[:warning] = 'The record you selected is a duplicate; you have been redirected to the original record.'
      redirect_to request.original_url.gsub(/\/\d+\//, "/#{@translation.duplicate_of_id}/")
    end
  end
end
