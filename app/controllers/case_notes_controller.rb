class CaseNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_access
  before_action :set_case_note, except: [:new, :create, :get]
  before_action :check_owner, except: [:new, :create, :get]
  before_action :set_rescue_request

  # ==============
  # In ArtOfCode's brach, many of these (#destroy, #create, #update) use the private return_status
  # private method. I've avoided doing so, because the redirects are more user-friendly, but may
  # revisit later because I have a feeling they're important for CAD.
  # ==============

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

  def edit; end

  def update
    if @case_note.update(note_params)
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
    if @case_note.destroy
      flash[:success] = 'Removed case note successfully.'
    else
      flash[:danger] = "Couldn't remove case note."
    end
    redirect_to disaster_request_path(disaster_id: did, num: num)
  end

  def get
    render json: { items: @rescue_request.case_notes }
  end

  private

  def check_access
    require_any :developer, :admin, :triage, :rescue, :medical
  end

  def check_owner
    require_any :developer, :admin unless current_user.present? && @case_note.user == current_user
  end

  def note_params
    params.require(:case_note).permit(:content, :rescue_request_id, :medical)
  end

  def set_case_note
    @case_note = CaseNote.find params[:id]
  end

  def set_rescue_request
    @request = RescueRequest.find(params[:rid])
  end

  # Possibly unnceccesary -- see comment at top
  def render_status(status, object)
    data = { success: status }
    data[:errors] = object.errors.full_messages unless status
    render json: data
  end
end
