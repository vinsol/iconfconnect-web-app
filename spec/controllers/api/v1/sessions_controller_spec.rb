require 'spec_helper'

describe Api::V1::SessionsController do

  before do
    @current_user = double(:user)
    User.stub(:where).with(:access_token => 'edeed').and_return(@current_user)
    @current_user.stub(:first).and_return(@current_user)
  end

  def set_session
    @session = double(:session)
    Session.stub(:where).with(:id => '300').and_return(@session)
    @session.stub(:first).and_return(@session)
  end

  def set_event
    @event = double(:event)
    Event.stub(:where).with(:id => '146').and_return(@event)
    @event.stub(:first).and_return(@event)
  end

  describe 'callbacks' do
    describe '#set_session' do
      context 'when session found' do
        before do
          set_session
          controller.params = ActionController::Parameters.new(id: '300')
        end
        it 'should assign @session' do
          controller.send(:set_session)
          expect(assigns[:session]).to eql @session
        end
      end

      context 'when session not found' do
        before do
          controller.params = ActionController::Parameters.new(id: '10000')
        end
        it 'should render json with a message and status' do
          controller.should_receive(:render).with(json: {message: 'Resource not found'}, status: 404)
          controller.send(:set_session)
        end
      end
    end

    describe '#set_event' do
      context 'when event found' do
        before do
          set_event
          controller.params = ActionController::Parameters.new(event_id: '146')
        end
        it 'should assign @event' do
          controller.send(:set_event)
          expect(assigns[:event]).to eql @event
        end
      end

      context 'when not found' do
        before do
          controller.params = ActionController::Parameters.new(event_id: '14600')
        end
        it 'should render json with message and status' do
          controller.should_receive(:render).with(json: {message: 'Event not found'}, status: 404)
          controller.send(:set_event)
        end
      end
    end
  end

  context '#index' do
    before do
      @sessions = double(:sessions)
      set_event
      @event.stub_chain(:sessions, :enabled).and_return(@sessions)
      get :index, :event_id => '146', :format => 'json', :token => 'edeed'
    end

    it 'should receive a json request' do
      expect(response.content_type).to eql 'application/json'
    end

    it 'should assign sessions' do
      expect(assigns[:sessions]).to eql @sessions
    end

    it 'should render :index template' do
      expect(response).to render_template :index
    end

  end

  context '#attendees' do
    before do
      @users = double(:users)
      set_session
      @session.stub(:attendes).and_return(@users)
      get :attendees, :id => '300', :event_id => '146', :format => 'json', :token => 'edeed'
    end
    it 'should receive a json request' do
      expect(response.content_type).to eq 'application/json'
    end
    it 'should assign users' do
      expect(assigns[:users]).to eql @users
    end
    it 'should render attendees template' do
      expect(response).to render_template :attendees
    end
  end

  context '#rsvp' do
    before do
      set_session
    end
    context 'when user is attending session' do
      before do
        @current_user.stub(:attending?).with(@session).and_return(true)
        get :rsvp, :id => '300', :event_id => '146', :format => 'json', :token => 'edeed'
      end
      it 'should render rsvp json' do
        expect(response.content_type).to eql 'application/json' 
      end

      it 'should set the status attending' do
        expect(response.body).to eql '{"status":"attending"}'
      end
    end

    context 'when user is not attending the session' do
      before do
        @current_user.stub(:attending?).with(@session).and_return(false)
        get :rsvp, :id => '300', :event_id => '146', :format => 'json', :token => 'edeed'
      end
      it 'should render rsvp json' do
        expect(response.content_type).to eql 'application/json'
      end

      it 'should set the status to not attending' do
        expect(response.body).to eql '{"status":"not attending"}'
      end
    end
  end

  context '#create_rsvp' do
    def do_create_rsvp
      get :create_rsvp, :id => 300, :event_id => 146, :format => 'json', :token => 'edeed'
    end
    before do
      @rsvp = double(:rsvp)
      set_session
      Rsvp.stub(:where).with(:session => @session, :user => @current_user).and_return(@rsvp)
      @session.stub_chain(:rsvps, :build).and_return(@rsvp)
      @rsvp.stub(:save).and_return(true)
    end

    it 'should assign rsvp' do
      do_create_rsvp
      expect(assigns[:rsvp]).to eql @rsvp
    end
    context 'when rsvp saved sucessfully' do
      
      it 'should should set message to success' do
        do_create_rsvp
        expect(response.body).to eql '{"message":"success"}'
      end
      it 'should set status to 200' do
        do_create_rsvp
        expect(response.status).to eql 200
      end
    end

    context 'when rsvp not saved' do
      before do
        @rsvp.stub(:save).and_return(false)
      end
      it 'should set message to unsuccessfull' do
        do_create_rsvp
        expect(response.body).to eql '{"message":"unsuccessfull"}'
      end
      it 'should set status to 404' do
        do_create_rsvp
        expect(response.status).to eql 404
      end
    end

  end

  context '#destroy_rsvp' do
    def do_destroy_rsvp
      get :destroy_rsvp, :id => 300, :event_id => 146, :format => 'json', :token => 'edeed'
    end
    before do
      @rsvp = double(:rsvp)
      set_session
      @session.stub_chain(:rsvps, :find_by).with(:user => @current_user).and_return(@rsvp)
      @rsvp.stub(:destroy).and_return(true)
    end

    it 'should assign rsvp' do
      do_destroy_rsvp
      expect(assigns[:rsvp]).to eql @rsvp
    end

    context 'when successfully destroyed' do
      it 'should should set message to success' do
        do_destroy_rsvp
        expect(response.body).to eql '{"message":"success"}'
      end
      it 'should set status to 200' do
        do_destroy_rsvp
        expect(response.status).to eql 200
      end
    end

    context 'when not destroyed' do
      before do
        @rsvp.stub(:destroy).and_return(false)
      end

      it 'should set message to unsuccessfull' do
        do_destroy_rsvp
        expect(response.body).to eql '{"message":"unsuccessfull"}'
      end
      it 'should set status to 404' do
        do_destroy_rsvp
        expect(response.status).to eql 404
      end

    end

  end
end