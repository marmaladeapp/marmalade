class App::GroupsController < App::AppController
  #authorize_resource

  def show
    @group = Group.find(params[:id])
    @context = @group
    authorize! :show, @group, :message => ""
    @abstracts = @group.abstracts
  end
  def new
    @user = current_user
    authorize! :new, Group, :message => ""
    @group = Group.new
  end
  def edit
    @user = current_user
    @group = Group.find(params[:id])
    authorize! :edit, @group, :message => ""
    @context = @group
  end
  def create
    @user = current_user
    authorize! :create, Group, :message => ""
    @group = Group.new(group_params)
    @group.user_id = @user.id
    if @group.save
      @group.ownerships.each do |ownership|
        #ownership.update_balance_sheets(:value => ownership.item.net_worth,:current_assets => ownership.item.current_assets,:fixed_assets => ownership.item.fixed_assets,:current_liabilities => ownership.item.current_liabilities,:long_term_liabilities => ownership.item.long_term_liabilities,:cash => ownership.item.cash,:ledgers_receivable => ownership.item.total_ledgers_receivable,:ledgers_debt => ownership.item.total_ledgers_debt,:wallets => ownership.item.total_wallets,:item => ownership.item,:action => 'create')
      end
      @group.abstracts.create(:item => @group, :user => current_user, :action => 'create')

      redirect_to group_path(@group)
    else
      render 'new'
    end
  end

  def update
    @user = current_user
    @group = Group.find(params[:id])
    @context = @group
    authorize! :update, @group, :message => ""
    if @group.update_attributes(group_params)
      redirect_to group_path(@group)
    else
      render 'edit'
    end
  end

  def destroy
    @group = Group.find(params[:id])
    authorize! :destroy, @group, :message => ""
    @resource = @group
    @group.owners.each do |ownership|
      ownership.update_balance_sheets(:value => - @resource.net_worth,:current_assets => - @resource.current_assets,:fixed_assets => - @resource.fixed_assets,:current_liabilities => - @resource.current_liabilities,:long_term_liabilities => - @resource.long_term_liabilities,:cash => - @resource.cash,:ledgers_receivable => - @resource.total_ledgers_receivable,:ledgers_debt => - @resource.total_ledgers_debt,:wallets => - @resource.total_wallets,:capital_assets => - @resource.capital_assets,:inventory => - @resource.inventory,:item => @resource,:action => 'update')
    end
    @group.destroy
    redirect_to root_path
  end

  private

  def group_params
    params.require(:group).permit(:name,:description,:currency,:country,:time_zone)
  end
end
