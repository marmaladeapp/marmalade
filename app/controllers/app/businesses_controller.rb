class App::BusinessesController < App::AppController
  #authorize_resource

  def show
    @business = Business.find(params[:id])
    @context = @business
    authorize! :show, @business, :message => ""
    @abstracts = @business.abstracts
  end
  def new
    @user = current_user
    authorize! :new, Business, :message => "You cannot create any more businesses. Please upgrade your plan to add another."
    @business = Business.new
  end
  def edit
    @user = current_user
    @business = Business.find(params[:business_id])
    authorize! :edit, @business, :message => ""
    @context = @business
  end
  def create
    @user = current_user
    @business = Business.new(business_params)
    authorize! :create, Business, :message => "You cannot create any more businesses. Please upgrade your plan to add another."
    @business.user_id = @user.id
    if @business.save
      @business.ownerships.each do |ownership|
        #ownership.update_balance_sheets(:value => ownership.item.net_worth,:current_assets => ownership.item.current_assets,:fixed_assets => ownership.item.fixed_assets,:current_liabilities => ownership.item.current_liabilities,:long_term_liabilities => ownership.item.long_term_liabilities,:cash => ownership.item.cash,:ledgers_receivable => ownership.item.total_ledgers_receivable,:ledgers_debt => ownership.item.total_ledgers_debt,:wallets => ownership.item.total_wallets,:item => ownership.item,:action => 'create')
      end
      @business.abstracts.create(:item => @business, :user => current_user, :action => 'create')

      redirect_to vanity_path(@business)
    else
      render 'new'
    end
  end

  def update
    @user = current_user
    @business = Business.find(params[:business_id])
    @context = @business
    authorize! :update, @business, :message => ""
    if @business.update_attributes(business_params)
      redirect_to vanity_path(@business)
    else
      render 'edit'
    end
  end

  def destroy
    @business = Business.find(params[:business_id])
    authorize! :destroy, @business, :message => ""
    @resource = @business
    @business.owners.each do |ownership|
      ownership.update_balance_sheets(:value => - @resource.net_worth,:current_assets => - @resource.current_assets,:fixed_assets => - @resource.fixed_assets,:current_liabilities => - @resource.current_liabilities,:long_term_liabilities => - @resource.long_term_liabilities,:cash => - @resource.cash,:ledgers_receivable => - @resource.total_ledgers_receivable,:ledgers_debt => - @resource.total_ledgers_debt,:wallets => - @resource.total_wallets,:capital_assets => - @resource.capital_assets,:inventory => - @resource.inventory,:item => @resource,:action => 'update')
    end
    @business.destroy
    redirect_to root_path
  end

  private

  def business_params
    params.require(:business).permit(:name,:description,:currency,:country,:time_zone) # ,:owners_attributes => [:user_id,:global_owner,:equity]
  end
end
