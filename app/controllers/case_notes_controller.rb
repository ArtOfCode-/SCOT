class CaseNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_access
  before_action :set_case_note, except: [:new, :create]

  def new
    @case_note = CaseNote.new
  end

  def create
    @case_note = CaseNote.new note_params
    @case_note.user = current_user
    if @case_note.save
      flash[:success] = 'Case note saved.'
      redirect_to disaster_request_path(disaster_id: @case_note.rescue_request.disaster_id, num: @case_note.rescue_request.incident_number)
    else
      flash[:danger] = "Couldn't save your case note."
      render :new
    end
  end

  def edit
    redirect_back(fallback_location: disaster_request_path(num: @case_note.rescue_request.id, disaster_id: @case_note.rescue_request.disaster.id)) unless @case_note.user == current_user
  end

  def update
    if @case_note.user == current_user && @case_note.update(note_params)
      flash[:success] = 'Case note saved.'
      redirect_to disaster_request_path(disaster_id: @case_note.rescue_request.disaster_id, num: @case_note.rescue_request.incident_number)
    else
      flash[:danger] = "Couldn't save your case note."
      render :edit
    end
  end

  def destroy
    did = @case_note.rescue_request.disaster_id
    num = @case_note.rescue_request.incident_number
    if @case_note.user == current_user && @case_note.destroy
      flash[:success] = 'Removed case note successfully.'
    else
      flash[:danger] = "Couldn't remove case note."
    end
    redirect_to disaster_request_path(disaster_id: did, num: num)
  end

  private

  def verify_access
    require_any :developer, :admin, :triage, :rescue
  end

  def note_params
    params.require(:case_note).permit(:content, :rescue_request_id, :medical)
  end

  def set_case_note
    @case_note = CaseNote.find params[:id]
  end
end
