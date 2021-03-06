class EventSessionsController < ApplicationController
  before_action :set_event_session, only: [:show, :edit, :update, :destroy]

  #FIXME_AB: delete unused actoins
  #FIXME_AB: authorization? for update and edit/destroy

  # GET /event_sessions
  # GET /event_sessions.json
  def index
    #FIXME_AB: De we need this action. Are we displaying all sessions regardless of event?
    @event_sessions = EventSession.all
  end

  # GET /event_sessions/1
  # GET /event_sessions/1.json
  def show
    @event_session = EventSession.find(params[:event_session_id])
  end

  # GET /event_sessions/new
  def new
    @event = Event.find(params[:event_id])
    @event_session = EventSession.new
  end

  # GET /event_sessions/1/edit
  def edit
    @event = Event.find(params[:event_id])
    @event_session = @event.event_sessions.find(params[:id])
  end

  # POST /event_sessions
  # POST /event_sessions.json
  def create
    @event = Event.find(params[:event_id])
    @event_session = @event.event_sessions.build(event_session_params)
    respond_to do |format|
      if @event_session.save
        format.html { redirect_to @event, notice: 'Event session was successfully created.' }
        format.json { render :show, status: :created, location: @event_session }
      else
        format.html { render :new }
        format.json { render json: @event_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_sessions/1
  # PATCH/PUT /event_sessions/1.json
  def update
    respond_to do |format|
      if @event_session.update(event_session_params)
        format.html { redirect_to @event_session.event, notice: 'Event session was successfully updated.' }
        format.json { render :show, status: :ok, location: @event_session }
      else
        format.html { render :edit }
        format.json { render json: @event_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_sessions/1
  # DELETE /event_sessions/1.json
  def destroy
    @event_session.destroy
    respond_to do |format|
      format.html { redirect_to event_sessions_url, notice: 'Event session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_session
      @event_session = EventSession.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_session_params
      params.require(:event_session).permit(:topic, :start_date, :end_date, :location, :speaker, :description, :status, :event_id)
    end
end
