class App::Time::TimeSheetsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @time_sheets =  @resource.time_sheets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @time_sheets = @household.time_sheets
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @time_sheets = @group.time_sheets
    else
      @time_sheets = current_user.time_sheets
      @time_sheets += ::TimeTracking::TimeSheet.where(:owner => current_user.businesses.to_a)
      @time_sheets += ::TimeTracking::TimeSheet.where(:owner => current_user.households.to_a)
      @time_sheets += ::TimeTracking::TimeSheet.where(:owner => current_user.groups.to_a)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @time_sheet =  @resource.time_sheets.find(params[:id])
      @timers = @time_sheet.timers.page(params[:page]) #.per(2)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @time_sheet = @household.time_sheets.find(params[:id])
      @timers = @time_sheet.timers.page(params[:page]) #.per(2)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @time_sheet = @group.time_sheets.find(params[:id])
      @timers = @time_sheet.timers.page(params[:page]) #.per(2)
    end
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
    @time_sheet = ::TimeTracking::TimeSheet.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @time_sheet =  @resource.time_sheets.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @resource = @context
      @time_sheet = @household.time_sheets.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @resource = @context
      @time_sheet = @group.time_sheets.find(params[:id])
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
    @time_sheet = @resource.time_sheets.new(time_sheet_params)
    @time_sheet.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @time_sheet.save
      @context.abstracts.create(:item => @time_sheet, :user => current_user, :action => 'create')
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
      @time_sheet =  @resource.time_sheets.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @time_sheet = @household.time_sheets.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @time_sheet = @group.time_sheets.find(params[:id])
    end
    if @time_sheet.update_attributes(time_sheet_params)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @time_sheet =  @resource.time_sheets.find(params[:id])
      @time_sheet.destroy
      redirect_to resource_timers_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @context, :message => ""
      @time_sheet = @household.time_sheets.find(params[:id])
      @time_sheet.destroy
      redirect_to user_home_timers_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @context, :message => ""
      @time_sheet = @group.time_sheets.find(params[:id])
      @time_sheet.destroy
      redirect_to group_timers_path(@group)
    end
  end

  private

  def time_sheet_params
    params.require(:time_tracking_time_sheet).permit(:name,:description)
  end
end
