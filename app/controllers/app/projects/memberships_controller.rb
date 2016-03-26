class App::Projects::MembershipsController < App::AppController
  def index
  end
  def show
  end
  def new
    if params[:resource_id]
      @business = VanityUrl.find(params[:resource_id]).owner
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = Membership.new
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = Membership.new
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = Membership.new
    end
    ids = []
    @project.members.each do |member|
      ids << member.id
    end
    @options_for_member_select = @resource.members.where.not(:id => ids)
  end
  def create
    if params[:resource_id]
      @business = VanityUrl.find(params[:resource_id]).owner
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.new(membership_params)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.new(membership_params)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.new(membership_params)
    end
    @membership.user = @resource.user
    if @membership.member && !@membership.member.is_member?(@membership.collective) && @membership.save
      @context.abstracts.create(:item => @membership, :user => current_user, :project => @project, :action => 'create')
      @membership.member.abstracts.create(:item => @membership, :user => current_user, :project => @project, :action => 'create')
      if params[:resource_id]
        redirect_to resource_project_path(@business,@project)
      elsif params[:group_id]
        redirect_to group_project_path(@group,@project)
      else
        redirect_to user_home_project_path(@user,@project)
      end
    else
      ids = []
      @project.members.each do |member|
        ids << member.id
      end
      @options_for_member_select = @resource.members.where.not(:id => ids)
      render 'new'
    end
  end
  def edit
    if params[:resource_id]
      @business = VanityUrl.find(params[:resource_id]).owner
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @project = @resource.projects.find(params[:project_id])
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
    end
  end
  def update
    if params[:resource_id]
      @business = VanityUrl.find(params[:resource_id]).owner
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
      redirect_to resource_project_path(@business,@project)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
      redirect_to group_project_path(@group,@project)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
      redirect_to user_home_project_path(@user,@project)
    end
  end
  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
      @membership.destroy
      redirect_to resource_project_path(@resource,@project)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @project = @group.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
      @membership.destroy
      redirect_to group_project_path(@group,@project)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @project = @household.projects.find(params[:project_id])
      authorize! :manage, @project, :message => ""
      @membership = @project.memberships.find_by(:member => User.find(params[:id]))
      @membership.destroy
      redirect_to user_home_project_path(@user,@project)
    end
  end
  private
  def membership_params
    params.require(:membership).permit(:global_collective,:global_member)
  end
end