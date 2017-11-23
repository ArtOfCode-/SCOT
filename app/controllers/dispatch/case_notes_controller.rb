class Dispatch::CaseNotesController < ApplicationController
  before_action :check_access
  before_action :set_note, except: [:new, :create]
  before_action :set_request

  def new
    @note = @request.case_notes.new
  end

  def create
    @note = @request.case_notes.new note_params.merge(author: current_user)
    if @note.save
      flash[:success] = 'Saved case note.'
      redirect_to cad_request_path(@request.disaster, @request)
    else
      flash[:danger] = 'Failed to save case note.'
      render :new
    end
  end

  def edit; end

  def update
    if @note.update note_params
      flash[:success] = 'Updated case note.'
      redirect_to cad_request_path(@request.disaster, @request)
    else
      flash[:danger] = 'Failed to update case note.'
      render :edit
    end
  end

  def destroy
    if @note.destroy
      flash[:success] = 'Removed case note.'
    else
      flash[:danger] = 'Failed to remove case note.'
    end
    redirect_to cad_request_path(@request.disaster, @request)
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end

  def note_params
    params.require(:dispatch_case_note).permit(:content, :medical)
  end

  def set_note
    @note = Dispatch::CaseNote.find params[:id]
  end

  def set_request
    @request = Dispatch::Request.find params[:rid]
  end

  def render_status(status, object)
    data = { success: status }
    data[:errors] = object.errors.full_messages unless status
    render json: data
  end
end
