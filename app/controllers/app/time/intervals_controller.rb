class App::Time::IntervalsController < App::AppController
  def index
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    end
    @interval = @timer.intervals.find(params[:id])
  end

  def new
  end

  def edit
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    end
    @interval = @timer.intervals.new(interval_params)
    @interval.started_at = DateTime.now
    if @interval.save
      if params[:resource_id]
        redirect_to resource_timer_interval_path(@resource,@timer,@interval)
      elsif params[:user_id]
        redirect_to user_home_timer_interval_path(@user,@timer,@interval)
      elsif params[:group_id]
        redirect_to group_timer_interval_path(@resource,@timer,@interval)
      end
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    end
    @interval = @timer.intervals.find(params[:id])
    @interval.stopped_at = DateTime.now

    @interval.duration = (@interval.stopped_at - @interval.started_at).to_i

    if @interval.update_attributes(interval_params)
      @timer.update_attributes(:elapsed_time => @timer.elapsed_time + @interval.duration)
      if params[:resource_id]
        redirect_to resource_timer_path(@resource,@timer)
      elsif params[:user_id]
        redirect_to user_home_timer_path(@user,@timer)
      elsif params[:group_id]
        redirect_to group_timer_path(@resource,@timer)
      end
    else
      render 'new'
    end
  end

  def destroy
  end

  private

  def interval_params
    params.require(:time_tracking_interval).permit(:duration,:user_id)
  end

end
