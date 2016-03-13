class App::Projects::Finances::WalletsController < App::AppController

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
      redirect = resource_project_finances_path(@resource,@project)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @project = @household.projects.find(params[:project_id])
      redirect = user_home_project_finances_path(@user,@project)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @project = @group.projects.find(params[:project_id])
      redirect = group_project_finances_path(@group,@project)
    end
    @project_wallet = @project.item_wallets.new(item_wallet_params)
    if @project_wallet.save
      @context.abstracts.create(:item => @project_wallet, :user => current_user, :action => 'create')
      redirect_to redirect
    else
      render 'new'
    end
  end

  def destroy
  end

  private

  def item_wallet_params
    params.require(:item_wallet).permit(:finances_wallet_id)
  end

end
