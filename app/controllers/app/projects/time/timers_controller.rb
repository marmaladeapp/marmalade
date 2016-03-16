class App::Projects::Time::TimersController < App::AppController

  def index
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
    else
      @project = current_user.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @timers = @project.timers
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @context.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer =  @project.timers.find(params[:id])
      @time_sheets =  @timer.time_sheets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @project =  @context.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:id])
      @time_sheets = @timer.time_sheets
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @project =  @context.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:id])
      @time_sheets = @timer.time_sheets
    end
    @interval = ::TimeTracking::Interval.new
    @intervals = @timer.intervals.page(params[:page]) #.per(2)
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
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @group
      @project = @group.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @timer = ::TimeTracking::Timer.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer =  @project.timers.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:id])
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
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @group
      @project = @group.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @timer = @project.timers.new(timer_params)
    @timer.context = @context
    if @timer.save
      @context.abstracts.create(:item => @timer, :user => current_user, :project => @project, :action => 'create')
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
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer =  @project.timers.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:id])
    end
    if @timer.update_attributes(timer_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
  end

  def time_sheets
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer =  @project.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @project =  @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    end
    @time_sheets = @timer.time_sheets
  end

  private

  def timer_params
    params.require(:time_tracking_timer).permit(:name,:description,:estimated_time,:owners_attributes => [:user_id,:global_owner])
  end
end
