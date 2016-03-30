class App::ProjectsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @resource, :message => ""
      @projects =  @resource.projects
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      authorize! :show, @household, :message => ""
      @projects = @household.projects
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @group, :message => ""
      @projects = @group.projects
    else
      @projects = current_user.projects
      @projects += Project.where(:owner => current_user.businesses.to_a)
      @projects += Project.where(:owner => current_user.households.to_a)
      @projects += Project.where(:owner => current_user.groups.to_a)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @project = @context.projects.find(params[:id])
    authorize! :show, @project, :message => ""
    @abstracts = @context.abstracts.where(:project => @project)
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    authorize! :new, Project, :message => ""
    @project = Project.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @project = @resource.projects.find(params[:id])
    authorize! :edit, @project, :message => ""
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    authorize! :create, Project, :message => ""
    @project = @resource.projects.new(project_params)
    @project.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @project.save
      @context.abstracts.create(:item => @project, :user => current_user, :project => @project, :action => 'create')
      if params[:resource_id]
        redirect_to resource_project_path(@resource,@project)
      elsif params[:user_id]
        redirect_to user_home_project_path(@user,@project)
      elsif params[:group_id]
        redirect_to group_project_path(@resource,@project)
      end
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @project = @resource.projects.find(params[:id])
    authorize! :update, @project, :message => ""
    if @project.update_attributes(project_params)
      if params[:resource_id]
        redirect_to resource_project_path(@resource,@project)
      elsif params[:user_id]
        redirect_to user_home_project_path(@user,@project)
      elsif params[:group_id]
        redirect_to group_project_path(@resource,@project)
      end
    else
      render 'edit'
    end
  end

  def destroy
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      authorize! :show, @business, :message => ""
      @project = @business.projects.find(params[:id])
      authorize! :destroy, @project, :message => ""
      @project.destroy
      redirect_to vanity_path(@business)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @project = @group.projects.find(params[:id])
      authorize! :destroy, @project, :message => ""
      @project.destroy
      redirect_to group_path(@group)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @project = @household.projects.find(params[:id])
      authorize! :destroy, @project, :message => ""
      @project.destroy
      redirect_to user_home_path(@user)
    end
  end

  private

  def project_params
    params.require(:project).permit(:name,:description)
  end
end
