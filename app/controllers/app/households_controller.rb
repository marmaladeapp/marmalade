class App::HouseholdsController < App::AppController

  def show
    @user = User.find(params[:user_id])
    @household = @user.home
    @context = @household
  end
  def new
    @user = User.find(params[:user_id])
    @household = Household.new
  end
  def edit
    @user = User.find(params[:user_id])
    @household = @user.home
    @context = @household
  end
  def create
    @user = User.find(params[:user_id])
    @household = Household.new(household_params)
    @household.currency = @user.currency
    @household.subscriber_id = @user.id
    if @household.save
      @household.ownerships.create(:owner => @household, :item => @user, :equity => BigDecimal.new(100))
      @household.ownerships.each do |ownership|
        #ownership.update_balance_sheets(:value => ownership.item.net_worth,:current_assets => ownership.item.current_assets,:fixed_assets => ownership.item.fixed_assets,:current_liabilities => ownership.item.current_liabilities,:long_term_liabilities => ownership.item.long_term_liabilities,:cash => ownership.item.cash,:ledgers_receivable => ownership.item.total_ledgers_receivable,:ledgers_debt => ownership.item.total_ledgers_debt,:wallets => ownership.item.total_wallets,:item => ownership.item,:action => 'create')
      end

      redirect_to user_home_path(@user)
    else
      render 'new'
    end
  end

  def update
    @user = User.find(params[:user_id])
    @household = @user.home
    @context = @household
    if @household.update_attributes(household_params)
      redirect_to user_home_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @household = @user.home
    @household.destroy
    redirect_to vanity_path(@user)
  end

  private

  def household_params
    params.require(:household).permit(:name,:description,:subscriber_id,:currency,:country,:time_zone)
  end
end
