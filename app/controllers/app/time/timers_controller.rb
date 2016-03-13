class App::Time::TimersController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @time_sheets =  @resource.time_sheets
      @timers =  @resource.timers.page(params[:page]) #.per(2)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @time_sheets = @household.time_sheets
      @timers = @household.timers.page(params[:page]) #.per(2)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @time_sheets = @group.time_sheets
      @timers = @group.timers.page(params[:page]) #.per(2)
    else
      @time_sheets = ::TimeTracking::TimeSheet.where(
        '(owner_type = ? AND owner_id = ?) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).page(params[:page]) #.per(2)
      @timers = ::TimeTracking::Timer.where(
        '(context_type = ? AND context_id = ?) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).page(params[:page]) #.per(2)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @timer =  ::TimeTracking::Timer.find(params[:id])
      @time_sheets =  @timer.time_sheets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @timer = ::TimeTracking::Timer.find(params[:id])
      @time_sheets = @timer.time_sheets
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @timer = ::TimeTracking::Timer.find(params[:id])
      @time_sheets = @timer.time_sheets
    end
    @interval = ::TimeTracking::Interval.new
    @intervals = @timer.intervals.page(params[:page]) #.per(2)
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
    if params[:time_sheet_id]
      @time_sheet = @resource.time_sheets.find(params[:time_sheet_id])
    end
    @timer = ::TimeTracking::Timer.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @timer =  ::TimeTracking::Timer.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      @timer = ::TimeTracking::Timer.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      @timer = ::TimeTracking::Timer.find(params[:id])
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


    @timer = @resource.timers.new(timer_params)
    if @timer.save
      @context.abstracts.create(:item => @timer, :user => current_user, :action => 'create')
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @timer =  ::TimeTracking::Timer.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      @timer = ::TimeTracking::Timer.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      @timer = ::TimeTracking::Timer.find(params[:id])
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
      @timer =  ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      @timer = ::TimeTracking::Timer.find(params[:timer_id])
    end
    @time_sheets = @timer.time_sheets
  end

  private

  def timer_params
    params.require(:time_tracking_timer).permit(:name,:description,:estimated_time,:owners_attributes => [:user_id,:global_owner])
  end
end
