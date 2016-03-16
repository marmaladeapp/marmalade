class App::Projects::Calendar::EventsController < App::AppController

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
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @project = @household.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @project = @group.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @ongoing_events = @project.events.where('starting_at <= ? AND ending_at >= ?', @start_date, @start_date).page(params[:page]) #.per(2)
    @events = @project.events.where(:starting_at => @start_date..@end_date).page(params[:page]) #.per(2)
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event =  @project.events.find(params[:id])
      @calendars =  @event.calendars
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:id])
      @calendars = @event.calendars
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:id])
      @calendars = @event.calendars
    end
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      authorize! :show, @context, :message => ""
      @project = @household.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      @context = @group
      authorize! :show, @context, :message => ""
      @project = @group.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @event = ::Calendar::Event.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event =  @project.events.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:id])
    end
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      authorize! :show, @context, :message => ""
      @project = @household.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      @context = @group
      authorize! :show, @context, :message => ""
      @project = @group.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @event = @project.events.new(event_params)
    @event.context = @resource
    if @event.save
      @context.abstracts.create(:item => @event, :user => current_user, :project => @project, :action => 'create')
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event =  @project.events.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:id])
    end
    if @event.update_attributes(event_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
  end

  def calendars
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event =  @project.events.find(params[:event_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:event_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @event = @project.events.find(params[:event_id])
    end
    @calendars = @event.calendars
  end
  
  private

  def event_params
    params.require(:calendar_event).permit(:name,:description,:"starting_at(1i)",:"starting_at(2i)",:"starting_at(3i)",:"starting_at(4i)",:"starting_at(5i)",:"ending_at(1i)",:"ending_at(2i)",:"ending_at(3i)",:"ending_at(4i)",:"ending_at(5i)",:owners_attributes => [:user_id,:global_owner])
  end
end

