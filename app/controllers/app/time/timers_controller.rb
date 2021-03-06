class App::Time::TimersController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @time_sheets =  @resource.time_sheets.limit(3)
      @timers =  @resource.timers.page(params[:page]) #.per(2)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @time_sheets = @household.time_sheets.limit(3)
      @timers = @household.timers.page(params[:page]) #.per(2)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @time_sheets = @group.time_sheets.limit(3)
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
      ).limit(3)
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
      authorize! :show, @context, :message => ""
      @timer =  @context.timers.find(params[:id])
      @time_sheets =  @timer.time_sheets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @timer = @context.timers.find(params[:id])
      @time_sheets = @timer.time_sheets
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @timer = @context.timers.find(params[:id])
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
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
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
      authorize! :show, @context, :message => ""
      @timer =  @context.timers.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:id])
    end
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
    end


    @timer = @resource.timers.new(timer_params)
    if @timer.save
      @context.abstracts.create(:item => @timer, :user => current_user, :action => 'create')
      if params[:resource_id]
        redirect_to resource_timer_path(@resource,@timer)
      elsif params[:user_id]
        redirect_to user_home_timer_path(@user,@timer)
      elsif params[:group_id]
        redirect_to group_timer_path(@context,@timer)
      end
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @timer =  @context.timers.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:id])
    end
    if params[:time_tracking_timer][:completed_at]
      params[:time_tracking_timer][:completed_at].blank? ? nil : DateTime.current
    end
    if @timer.update_attributes(timer_params)
      if params[:resource_id]
        redirect_to resource_timer_path(@resource,@timer)
      elsif params[:user_id]
        redirect_to user_home_timer_path(@user,@timer)
      elsif params[:group_id]
        redirect_to group_timer_path(@context,@timer)
      end
    else
      render 'edit'
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @timer =  @context.timers.find(params[:id])
      @timer.destroy
      redirect_to resource_timers_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:id])
      @timer.destroy
      redirect_to user_home_timers_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:id])
      @timer.destroy
      redirect_to group_timers_path(@group)
    end
  end

  def time_sheets
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @timer =  @context.timers.find(params[:timer_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:timer_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @timer = @context.timers.find(params[:timer_id])
    end
    @time_sheets = @timer.time_sheets
  end

  private

  def timer_params
    params.require(:time_tracking_timer).permit(:name,:description,:completed_at,:estimated_time,:owners_attributes => [:user_id,:global_owner,:id,:_destroy])
  end
end
