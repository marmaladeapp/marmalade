class App::Time::AssigneesController < App::AppController
  def index
  end
  def show
  end
  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = Membership.new
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = Membership.new
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = Membership.new
    end
    if @resource.class.name == 'User'
      ids = []
      @timer.members.each do |member|
        ids << member.id
      end
      @options_for_member_select = User.where(:id => current_user.id).where.not(:id => ids)
    else
      ids = []
      @timer.members.each do |member|
        ids << member.id
      end
      @options_for_member_select = @resource.members.where.not(:id => ids)
    end
  end
  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.new(membership_params)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.new(membership_params)
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.new(membership_params)
    end
    @membership.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @membership.member && !@membership.member.is_member?(@membership.collective) && @membership.save
      @context.abstracts.create(:item => @timer, :sub_item => @membership, :user => current_user, :action => 'assign')
      if params[:resource_id]
        redirect_to resource_timer_path(@resource,@timer)
      elsif params[:group_id]
        redirect_to group_timer_path(@group,@timer)
      else
        redirect_to user_home_timer_path(@user,@timer)
      end
    else
      if @resource.class.name == 'User'
        ids = []
        @timer.members.each do |member|
          ids << member.id
        end
        @options_for_member_select = User.where(:id => current_user.id).where.not(:id => ids)
      else
        ids = []
        @timer.members.each do |member|
          ids << member.id
        end
        @options_for_member_select = @resource.members.where.not(:id => ids)
      end
      render 'new'
    end
  end
  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
    end
  end
  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
      redirect_to resource_timer_path(@resource,@timer)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
      redirect_to group_timer_path(@group,@timer)
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
      redirect_to user_home_timer_path(@user,@timer)
    end
  end
  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
      @membership.destroy
      redirect_to resource_timer_path(@resource,@timer)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
      @membership.destroy
      redirect_to group_timer_path(@group,@timer)
    else
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
      @timer = @resource.timers.find(params[:timer_id])
      @membership = @timer.memberships.find(params[:id])
      @membership.destroy
      redirect_to user_home_timer_path(@user,@timer)
    end
  end
  private
  def membership_params
    params.require(:membership).permit(:global_collective,:global_member)
  end
end