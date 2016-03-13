class App::Projects::Messages::MessagesController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @project = @household.projects.find(params[:project_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @project = @group.projects.find(params[:project_id])
    else
      @project = current_user.projects.find(params[:project_id])
    end
    @message = ::Messages::Message.new
    @messages = @project.messages
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
      redirect = resource_project_messages_path(@resource,@project)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @project = @household.projects.find(params[:project_id])
      redirect = user_home_project_messages_path(@user,@project)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @project = @group.projects.find(params[:project_id])
      redirect = group_project_messages_path(@group,@project)
    end

    @message = @project.messages.new(message_params)
    @message.user = current_user
    @message.context = @context

    if @message.save
      @context.abstracts.create(:item => @message, :user => current_user, :project => @project, :action => 'create')
      redirect_to redirect
    else
      render 'new'
    end
  end

  def update
  end

  def destroy
  end

  private

  def message_params
    params.require(:messages_message).permit(:title,:content)
  end
end
