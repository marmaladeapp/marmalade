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

  def calendar_params
    params.require(:calendar_calendar).permit(:name,:description)
  end
end
