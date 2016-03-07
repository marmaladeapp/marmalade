class App::Calendar::AttendeesController < App::AppController
  def index
  end
  def show
  end
  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.new
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.new
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.new
    end
    ids = []
    @event.members.each do |member|
      ids << member.id
    end
    @options_for_member_select = @resource.members.where.not(:id => ids)
  end
  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = @event.memberships.new(membership_params)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = @event.memberships.new(membership_params)
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = @event.memberships.new(membership_params)
    end
    @membership.user = @resource.user
    if !@membership.member.is_member?(@membership.collective) && @membership.save
      if params[:resource_id]
        redirect_to resource_event_path(@resource,@event)
      elsif params[:group_id]
        redirect_to group_event_path(@group,@event)
      else
        redirect_to user_home_event_path(@user,@event)
      end
    else
      ids = []
      @event.members.each do |member|
        ids << member.id
      end
      @options_for_member_select = @resource.members.where.not(:id => ids)
      render 'new'
    end
  end
  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
    end
  end
  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
      redirect_to resource_event_path(@resource,@event)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
      redirect_to group_event_path(@group,@event)
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
      redirect_to user_home_event_path(@user,@event)
    end
  end
  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
      @membership.destroy
      redirect_to resource_event_path(@resource,@event)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
      @membership.destroy
      redirect_to group_event_path(@group,@event)
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      @event = ::Calendar::Event.find(params[:event_id])
      @membership = Membership.find(params[:id])
      @membership.destroy
      redirect_to user_home_event_path(@user,@event)
    end
  end
  private
  def membership_params
    params.require(:membership).permit(:global_collective,:global_member)
  end
end