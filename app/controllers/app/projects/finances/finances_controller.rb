class App::Projects::Finances::FinancesController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
      @context_wallets = @resource.wallets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @project = @household.projects.find(params[:project_id])
      @context_wallets = ::Finances::Wallet.where(
        '(context_type = ? AND context_id IN (?))', 
        'User', @household.members.ids
      )
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @project = @group.projects.find(params[:project_id])
      @context_wallets = ::Finances::Wallet.where(
        '(context_type = ? AND context_id IN (?))', 
        'User', @group.members.ids
      )
    end
    if @project.wallets.any?
      @wallet = @project.wallets.first
    else
      @project_wallet = ItemWallet.new
    end
    @payments = @project.payments.page(params[:page]) #.per(2)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

end
