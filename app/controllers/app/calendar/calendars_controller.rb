class App::Calendar::CalendarsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @calendars =  @resource.calendars
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @calendars = @household.calendars
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @calendars = @group.calendars
    else
      @calendars = current_user.calendars
      @calendars += ::Calendar::Calendar.where(:owner => current_user.businesses.to_a)
      @calendars += ::Calendar::Calendar.where(:owner => current_user.households.to_a)
      @calendars += ::Calendar::Calendar.where(:owner => current_user.groups.to_a)
    end
  end

  def show
    if params['s']
      @start_date = DateTime.new(params['s'][:'start_date(1i)'].to_i,params['s'][:'start_date(2i)'].to_i,params['s'][:'start_date(3i)'].to_i).beginning_of_day
      @end_date = DateTime.new(params['s'][:'end_date(1i)'].to_i,params['s'][:'end_date(2i)'].to_i,params['s'][:'end_date(3i)'].to_i).end_of_day
    else
      @start_date = DateTime.now.beginning_of_day
      @end_date = (DateTime.now + 6.days).end_of_day
    end
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @calendar =  @resource.calendars.find(params[:id])
      @ongoing_events = @calendar.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events = @calendar.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @calendar = @household.calendars.find(params[:id])
      @ongoing_events = @calendar.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events = @calendar.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @calendar = @group.calendars.find(params[:id])
      @ongoing_events = @calendar.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
      @events = @calendar.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
    end
    if false # clndr
      @clndr = Clndr.new(@calendar.name.parameterize.underscore.to_sym)
      @events.each do |event|
        if event.starting_at.noon == event.ending_at.noon
          @clndr.add_event(event.starting_at,event.name,description:event.description)
        else
          @clndr.add_multiday_event(event.starting_at,event.ending_at,event.name,description:event.description)
        end
      end
    end
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    @calendar = ::Calendar::Calendar.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @calendar =  @resource.calendars.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      @calendar = @household.calendars.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      @calendar = @group.calendars.find(params[:id])
    end
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    @calendar = @resource.calendars.new(calendar_params)
    @calendar.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @calendar.save
      @context.abstracts.create(:item => @calendar, :user => current_user, :action => 'create')
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @calendar =  @resource.calendars.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @calendar = @household.calendars.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @calendar = @group.calendars.find(params[:id])
    end
    if @calendar.update_attributes(calendar_params)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
  end

  private

  def calendar_params
    params.require(:calendar_calendar).permit(:name,:description)
  end
end
