class App::Projects::Time::TimersController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @project = @household.projects.find(params[:project_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @project = @group.projects.find(params[:project_id])
    else
      @project = current_user.projects.find(params[:project_id])
    end
    @timers = @project.timers
  end

  def show
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      @project = @household.projects.find(params[:project_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @group
      @project = @group.projects.find(params[:project_id])
    end
    @timer = ::TimeTracking::Timer.new
  end

  def edit
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      @project = @household.projects.find(params[:project_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @group
      @project = @group.projects.find(params[:project_id])
    end
    @timer = @project.timers.new(timer_params)
    @timer.context = @context
    if @timer.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
  end

  def destroy
  end

  private

  def timer_params
    params.require(:time_tracking_timer).permit(:name,:description,:estimated_time,:owners_attributes => [:user_id,:global_owner])
  end
end
