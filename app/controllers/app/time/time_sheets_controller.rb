class App::Time::TimeSheetsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @time_sheets =  @resource.time_sheets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @time_sheets = @household.time_sheets
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @time_sheets = @group.time_sheets
    else
      @time_sheets = current_user.time_sheets
      @time_sheets += ::TimeTracking::TimeSheet.where(:owner => current_user.businesses.to_a)
      @time_sheets += ::TimeTracking::TimeSheet.where(:owner => current_user.households.to_a)
      @time_sheets += ::TimeTracking::TimeSheet.where(:owner => current_user.groups.to_a)
    end
  end

  def show
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
    @time_sheet = ::TimeTracking::TimeSheet.new
  end

  def edit
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
    @time_sheet = @resource.time_sheets.new(time_sheet_params)
    @time_sheet.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @time_sheet.save
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

  def time_sheet_params
    params.require(:time_tracking_time_sheet).permit(:name,:description)
  end
end
