class App::Calendar::EventsController < App::AppController

  def index
    if params['s']
      @start_date = Time.zone.parse(params['s'][:'start_date(1i)'] + '-' + params['s'][:'start_date(2i)'] + '-' + params['s'][:'start_date(3i)']).to_datetime.beginning_of_day
      @end_date = Time.zone.parse(params['s'][:'end_date(1i)'] + '-' + params['s'][:'end_date(2i)'] + '-' + params['s'][:'end_date(3i)']).to_datetime.end_of_day
    else
      @start_date = DateTime.current.beginning_of_day
      @end_date = (DateTime.current + 6.days).end_of_day
    end
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @calendars =  @resource.calendars.limit(3)
      @ongoing_events = @resource.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events =  @resource.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @calendars = @household.calendars.limit(3)
      @ongoing_events = @household.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events = @household.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @calendars = @group.calendars.limit(3)
      @ongoing_events = @group.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events = @group.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    else
      @calendars = ::Calendar::Calendar.where(
        '(owner_type = ? AND owner_id = ?) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).limit(3)
      @ongoing_events = ::Calendar::Event.where(
        '(context_type = ? AND context_id = ?) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events = ::Calendar::Event.where(
        '(context_type = ? AND context_id = ?) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
      # @events = current_user.attended_events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @event =  @context.events.find(params[:id])
      @calendars =  @event.calendars
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @event = @context.events.find(params[:id])
      @calendars = @event.calendars
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @event = @context.events.find(params[:id])
      @calendars = @event.calendars
    end
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    if params[:calendar_id]
      @calendar = @resource.calendars.find(params[:calendar_id])
    end
    @event = ::Calendar::Event.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @event =  @context.events.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:id])
    end
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end


    @event = @resource.events.new(event_params)
    if @event.save
      @context.abstracts.create(:item => @event, :user => current_user, :action => 'create')
      if params[:resource_id]
        redirect_to resource_event_path(@resource,@event)
      elsif params[:user_id]
        redirect_to user_home_event_path(@user,@event)
      elsif params[:group_id]
        redirect_to group_event_path(@context,@event)
      end
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @event =  @context.events.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:id])
    end
    if @event.update_attributes(event_params)
      if params[:resource_id]
        redirect_to resource_event_path(@resource,@event)
      elsif params[:user_id]
        redirect_to user_home_event_path(@user,@event)
      elsif params[:group_id]
        redirect_to group_event_path(@context,@event)
      end
    else
      render 'edit'
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @event =  @context.events.find(params[:id])
      @event.destroy
      redirect_to resource_events_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:id])
      @event.destroy
      redirect_to user_home_events_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:id])
      @event.destroy
      redirect_to group_events_path(@group)
    end
  end

  def calendars
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @event =  @context.events.find(params[:event_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:event_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @event = @context.events.find(params[:event_id])
    end
    @calendars = @event.calendars
  end

  private

  def event_params
    params.require(:calendar_event).permit(:name,:description,:"starting_at(1i)",:"starting_at(2i)",:"starting_at(3i)",:"starting_at(4i)",:"starting_at(5i)",:"ending_at(1i)",:"ending_at(2i)",:"ending_at(3i)",:"ending_at(4i)",:"ending_at(5i)",:owners_attributes => [:user_id,:global_owner,:id,:_destroy])
  end
end
