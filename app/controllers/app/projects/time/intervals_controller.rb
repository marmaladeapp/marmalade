class App::Projects::Time::IntervalsController < App::AppController
  def index
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    end
    @interval = @timer.intervals.find(params[:id])
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    end
    @interval = @timer.intervals.new
  end

  def edit
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    end
    @interval = @timer.intervals.new(interval_params)
    @interval.project = @project
    hours = params[:hours] ? params[:hours].to_i : 0
    minutes = params[:minutes] ? params[:minutes].to_i : 0
    seconds = params[:seconds] ? params[:seconds].to_i : 0
    @interval.duration = (hours * (60 * 60)) + (minutes * 60) + seconds
    @interval.started_at = @interval.stopped_at - @interval.duration.seconds
    if @interval.save
      @context.abstracts.create(:item => @interval, :user => current_user, :project => @project, :action => 'create')
      @timer.update_attributes(:elapsed_time => @timer.elapsed_time + @interval.duration)
      if params[:resource_id]
        redirect_to resource_project_timer_path(@resource,@project,@timer)
      elsif params[:user_id]
        redirect_to user_home_project_timer_path(@user,@project,@timer)
      elsif params[:group_id]
        redirect_to group_project_timer_path(@resource,@project,@timer)
      end
    else
      render 'new'
    end
  end

  def update
  end

  def start
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    end
    @interval = @timer.intervals.new(interval_params)
    @interval.started_at = DateTime.now
    @interval.project = @project
    if @interval.save
      @context.abstracts.create(:item => @interval, :user => current_user, :project => @project, :action => 'start')
      if params[:resource_id]
        redirect_to resource_project_timer_interval_path(@resource,@project,@timer,@interval)
      elsif params[:user_id]
        redirect_to user_home_project_timer_interval_path(@user,@project,@timer,@interval)
      elsif params[:group_id]
        redirect_to group_project_timer_interval_path(@resource,@project,@timer,@interval)
      end
    else
      render 'new'
    end
  end

  def stop
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
      @timer = @project.timers.find(params[:timer_id])
    end
    @interval = @timer.intervals.find(params[:id])
    @interval.stopped_at = DateTime.now

    @interval.duration = (@interval.stopped_at - @interval.started_at).to_i

    if @interval.update_attributes(interval_params)
      @context.abstracts.create(:item => @interval, :user => current_user, :project => @project, :action => 'stop')
      @timer.update_attributes(:elapsed_time => @timer.elapsed_time + @interval.duration)
      if params[:resource_id]
        redirect_to resource_project_timer_path(@resource,@project,@timer)
      elsif params[:user_id]
        redirect_to user_home_project_timer_path(@user,@project,@timer)
      elsif params[:group_id]
        redirect_to group_project_timer_path(@resource,@project,@timer)
      end
    else
      render 'edit'
    end
  end

  def destroy
  end

  private

  def interval_params
    params.require(:time_tracking_interval).permit(:duration,:user_id,:"stopped_at(1i)",:"stopped_at(2i)",:"stopped_at(3i)",:"stopped_at(4i)",:"stopped_at(5i)")
  end

end
