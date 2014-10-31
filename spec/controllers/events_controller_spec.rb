require 'spec_helper'

describe EventsController do

  before do
    @user = double(:user)
    User.stub(:find).with(1).and_return(@user)
    controller.stub(:admin_signed_in?).and_return(false)
    controller.stub(:current_user).and_return(@user)
    controller.class.stub(:protect_from_forgery).with(:null_session).and_return(:null_session)
  end
  
  context '#index' do

    it 'should render the :index view' do
      get :index
      expect(response).to render_template(:index)
    end

  end

  context '#filter' do

    context 'when event is past' do

      before do
        @events = double(:events)
        Event.stub_chain(:past, :order_by_start_date).with(:desc).and_return(@events)
        xhr :get, :filter, :events => { :filter => 'past'}, :format => 'js'
      end

      it 'should assign @events to past events' do
        expect(assigns[:events]).to eql @events
      end
      
      it 'should render the :filter js' do
        expect(response.content_type).to eq 'text/javascript'
      end

    end

    context 'when event is upcoming' do

      before do
        @events = double(:events)
        Event.stub_chain(:live_and_upcoming, :order_by_start_date).with(:asc).and_return(@events)
        xhr :get, :filter, :events => { :filter => 'upcoming'}, :format => 'js'
      end

      it 'should assign events to upcoming events' do
        expect(assigns[:events]).to eql @events
      end

      it 'should render the :filter js' do
        expect(response.content_type).to eq 'text/javascript'
      end
    end

  end

  context '#mine_events' do

    before do
      @events = double(:events)
    end

    context 'when event is past' do

      before do
        @user.stub_chain(:my_created_past_events, :paginate).with({:page=>nil, :per_page=>5}).and_return(@events)
        xhr :get, :mine_events, :events => { :filter => 'past'}, :format => 'js'
      end

      it 'should assign events to my past events' do
        expect(assigns[:events]).to eql @events
      end
      
      it 'should render the :filter js' do
        expect(response.content_type).to eq 'text/javascript'
      end

    end

    context 'when event is upcoming' do

      before do
        @user.stub_chain(:my_created_upcoming_events, :paginate).with({:page=>nil, :per_page=>5}).and_return(@events)
        xhr :get, :mine_events, :events => { :filter => 'upcoming' }, :format => 'js'
      end

      it 'should assign events to my upcoming events' do
        expect(assigns[:events]).to eql @events
      end

      it 'should render the :filter js' do
        expect(response.content_type).to eq 'text/javascript'
      end
    end

  end

  context '#attending' do

    before do
      @events = double(:events)
    end

    context 'when event is past' do

      before do
        @user.stub_chain(:my_past_attended_events, :paginate).with({:page=>nil, :per_page=>5}).and_return(@events)
        @events.stub(:uniq).and_return(@events)
        xhr :get, :attending, :events => { :filter => 'past'}, :format => 'js'
      end

      it 'should assign events to my attending events' do
        expect(assigns[:events]).to eql @events
      end
      
      it 'should render the :filter js' do
        expect(response.content_type).to eq 'text/javascript'
      end

    end

    context 'when event is upcoming' do

      before do
        @user.stub_chain(:my_upcoming_attending_events, :paginate).with({:page=>nil, :per_page=>5}).and_return(@events)
        @events.stub(:uniq).and_return(@events)
        xhr :get, :attending, :events => { :filter => 'upcoming'}, :format => 'js'
      end

      it 'should assign events to my attending events' do
        expect(assigns[:events]).to eql @events
      end

      it 'should render the :filter js' do
        expect(response.content_type).to eq 'text/javascript'
      end
    end

  end

  context '#mine' do

    it 'should render the :mine events view' do
      get :mine
      expect(response).to render_template(:mine)
    end

  end


  context '#search' do

    before do
      @events = double(:events)
    end

    context 'when no paramaters is assigned' do

      before do
        xhr :get, :search, :search => '', :format => 'js'
      end

      it 'should generate js response' do
        expect(response.content_type).to eq 'text/javascript'
      end

      it 'should generate a sucessfull response' do
        expect(response.status).to eql 200
      end

    end

    context 'when a query is passed as parameters' do
      
      before do
        @rsvp = double(:rsvp)
        controller.stub_chain(:get_live_and_upcoming_events, :eager_load).with(:sessions).and_return(@rsvp)
        @rsvp.stub(:search).with('dp').and_return(@events)
        @events.stub(:paginate).with({:page=>nil, :per_page=>5}).and_return(@events)
        @events.stub(:uniq).and_return(@events)
        xhr :get, :search, :search => 'dp', :format => 'js'
      end

      it 'should assign events according to events that are searched for' do
        expect(assigns[:events]).to eql @events
      end

      it 'should render the :search js' do
        expect(response.content_type).to eq 'text/javascript'
      end
    end
  end

  context '#rsvps' do

    it 'should render the :rsvps view' do
      get :rsvps
      expect(response).to render_template(:rsvps)
    end

  end

  context '#show' do

    it 'should render the :show view' do
      get :show, :id => 1
      expect(response).to render_template(:show)
    end

  end

  context '#new' do

    before do
      @event = double(:event)
      @user.stub_chain(:events, :build).and_return(@event)
      get :new
    end

    it 'should assign @event' do
      expect(assigns[:event]).not_to be_nil
    end

    it 'should render the template :new' do
      expect(response).to render_template(:new)
    end

  end

  context 'get #edit' do

    before do
      controller.stub(:authorize_user?).and_return(:true)
      get :edit, :id => 142
    end

    it 'should render the :edit view' do
      expect(response).to render_template(:edit)
    end

  end

  context '#create' do
    before do
      @event = mock_model("Event")
      @event_params = { "name" => "dilpreet", "start_date" => "2014-10-23 06:13:05", "end_date" => "2014-10-26 06:13:05",
        "address" => "Hno. 1234", "city" => "Delhi", "country" => "India", "contact_number" => "131313", "description" => "ddqqdqdqd",
        "enable" => true }
    end

    def do_post
      post :create, { :event => @event_params }
    end

    context 'when logged in' do

      before do
        @user.stub_chain(:events, :build).with(@event_params).and_return(@event)
        @event.stub(:save).and_return(true)
      end 

      it 'should assign event' do
        do_post
        expect(assigns[:event]).to eql @event
      end

      it 'should redirect to event page' do
        do_post
        expect(response).to redirect_to(event_path(@event))
      end

      it 'should flash a notice' do
        do_post
        expect(flash[:notice]).to eql 'Event was successfully created.'
      end

      it 'should render :new when not saved' do
        @event.stub(:save).and_return(false)
        do_post
        expect(response).to render_template :new
      end

    end

    context 'when not logged in' do

      before do
        controller.stub(:admin_signed_in?).and_return(false)
        controller.stub(:current_user).and_return(false)
      end

      it 'should flash notice Please log in' do
        do_post
        expect(flash[:notice]).to eql 'Please log in to perform the current operation'
      end

    end

  end

  context '#update' do

    before do
      @event = mock_model("Event")
      Event.stub(:where).with(:id => '142').and_return(@event)
      @event.stub(:first).and_return(@event)
      @event.stub(:update).and_return(true)
      controller.stub(:authorize_user?).and_return(true)
    end

    def do_put(params = {})
      put :update, :id => '142', :event => {  "name" => "dsds" }
    end

    it 'should find the event' do
      event_params = { :name => 'dsds' }
      expect(Event).to receive(:where).with(:id => '142')
      do_put(event_params)
    end

    it 'should update the event' do
      event_params = { "name" => 'dsds' }
      expect(@event).to receive(:update).with(event_params).and_return(true)
      do_put(event_params)
    end

    it 'should redirect to event path' do
      event_params = { "name" => 'dsds' }
      do_put(event_params)
      expect(response).to redirect_to @event
    end

    it 'should flash notice' do
      event_params = { "name" => 'dsds' }
      do_put(event_params)
      expect(flash[:notice]).to eql 'Event was successfully updated.'
    end

    it 'should render edit: view' do
      @event.stub(:update).and_return(false)
      do_put
      expect(response).to render_template :edit
    end

  end
  
  context '#disable' do
   
    before do
      @event = double(:event)
      Event.stub(:where).with(:id => '142').and_return(@event)
      @event.stub(:first).and_return(@event)
      controller.stub(:authorize_user?).and_return(true)
    end

    context 'when successfully disabled' do

      before do
        @event.stub(:update_attribute).with('enable', false).and_return(true)
        xhr :get, :disable, :id => 142
      end

      it 'should assign event to current event' do
        expect(assigns[:event]).to eql @event
      end

      it 'should redirect to events page' do
        expect(response).to redirect_to events_url
      end

      it 'should flash a notice Event successfully disabled' do
        expect(flash[:notice]).to eq 'Event successfully Disabled'
      end

    end

    context 'when not disabled' do

      before do
        @event.stub(:update_attribute).with('enable', false).and_return(false)
        xhr :get, :disable, :id => 142
      end

      it 'should redirect to events page' do
        expect(response).to redirect_to events_url
      end

      it 'should flash a notice' do
        expect(flash[:notice]).to eq 'Event cannot be disabled'
      end

    end
         
  end 

end