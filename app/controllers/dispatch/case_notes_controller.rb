class Dispatch::CaseNotesController < ApplicationController
  before_action :check_access
  before_action :set_note, except: [:create, :get]
  before_action :set_request, except: [:update, :destroy]

  def create
    @note = @request.case_notes.new note_params.merge(author: current_user)
    render_status @note.save, @note
  end

  def update
    render_status @note.update(note_params), @note
  end

  def destroy
    render_status @note.destroy, @note
  end

  def get
    render json: { items: @request.case_notes }
  end

  private

  def check_access
    require_any :developer, :admin, :dispatch
  end

  def note_params
    params.require(:case_note).permit(:content, :medical)
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
