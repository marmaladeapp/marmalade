class App::Finances::WalletsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @wallets =  @resource.wallets
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @wallets = @household.wallets
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @wallets = @group.wallets
    else
      @wallets = current_user.wallets
      @wallets += ::Contacts::AddressBook.where(:owner => current_user.businesses.to_a)
      @wallets += ::Contacts::AddressBook.where(:owner => current_user.households.to_a)
      @wallets += ::Contacts::AddressBook.where(:owner => current_user.groups.to_a)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
    end
    @wallet = ::Finances::Wallet.find(params[:id])
    authorize! :show, @wallet, :message => ""
    @payments = @wallet.payments.order(created_at: :desc).page(params[:page]) #.per(2)
    if @payments.last == @wallet.payments.last || @payments.empty?
      @payments << ::Finances::Payment.new(:description => 'Starting Balance', :value => 0, :wallet_balance => @wallet.starting_balance, :created_at => @wallet.created_at, :currency => @wallet.currency)
    end
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
    end
    @wallet = ::Finances::Wallet.new
    if @resource.class.name == "Household"
      @ownerships = []
      @resource.members.each do |member|
        @ownerships << Ownership.new(:owner => member, :item => @wallet, :equity => BigDecimal.new(100) / @resource.members.count, :user_id => @resource.user.id)
      end
    else
      @ownerships = []
      @ownerships << Ownership.new(:owner => @resource, :item => @wallet, :equity => BigDecimal.new(100), :user_id => @resource.class.name == "User" ? @resource.id : @resource.user.id)
    end
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
    end
    params[:finances_wallet][:starting_balance] = BigDecimal.new(params[:finances_wallet][:starting_balance])
    @wallet = ::Finances::Wallet.new(wallet_params)
    @wallet.balance = @wallet.starting_balance
    @wallet.user = @resource.class.name == "User" ? current_user : @resource.user
    @wallet.context = @context
    authorize! :create, @wallet, :message => ""
    if @wallet.save
      @context.abstracts.create(:item => @wallet, :user => current_user, :action => 'create')
      @wallet.owners.each do |ownership|
        if @wallet.balance >= 0
          ownership.update_balance_sheets(:value => @wallet.balance,:current_assets => @wallet.balance,:cash => @wallet.balance, :wallets => @wallet.balance,:item => @wallet,:action => 'create')
        else
          ownership.update_balance_sheets(:value => @wallet.balance,:current_liabilities => - @wallet.balance, :wallets => @wallet.balance,:item => @wallet,:action => 'create')
        end
      end
      if params[:resource_id]
        redirect_to resource_wallet_path(@resource,@wallet)
      elsif params[:user_id]
        redirect_to user_home_wallet_path(@user,@wallet)
      elsif params[:group_id]
        redirect_to group_wallet_path(@context,@wallet)
      end
    else
      render 'new'
    end
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :edit, @wallet, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :edit, @wallet, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :edit, @wallet, :message => ""
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :update, @wallet, :message => ""
      if @wallet.update_attributes(wallet_params)
        redirect_to resource_wallet_path(@resource,@wallet)
      else
        render 'edit'
      end
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :update, @wallet, :message => ""
      if @wallet.update_attributes(wallet_params)
        redirect_to user_home_wallet_path(@user,@wallet)
      else
        render 'edit'
      end
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :update, @wallet, :message => ""
      if @wallet.update_attributes(wallet_params)
        redirect_to group_wallet_path(@resource,@wallet)
      else
        render 'edit'
      end
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :destroy, @wallet, :message => ""
      @wallet.owners.each do |ownership|
        if @wallet.balance >= 0
          ownership.update_balance_sheets(:value => - @wallet.balance,:current_assets => - @wallet.balance,:cash => - @wallet.balance, :wallets => - @wallet.balance,:item => @wallet,:action => 'destroy')
        else
          ownership.update_balance_sheets(:value => - @wallet.balance,:current_liabilities => @wallet.balance, :wallets => - @wallet.balance,:item => @wallet,:action => 'destroy')
        end
      end
      @wallet.destroy
      redirect_to resource_finances_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :destroy, @wallet, :message => ""
      @wallet.owners.each do |ownership|
        if @wallet.balance >= 0
          ownership.update_balance_sheets(:value => - @wallet.balance,:current_assets => - @wallet.balance,:cash => - @wallet.balance, :wallets => - @wallet.balance,:item => @wallet,:action => 'destroy')
        else
          ownership.update_balance_sheets(:value => - @wallet.balance,:current_liabilities => @wallet.balance, :wallets => - @wallet.balance,:item => @wallet,:action => 'destroy')
        end
      end
      @wallet.destroy
      redirect_to user_home_finances_path(@user)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @wallet = ::Finances::Wallet.find(params[:id])
      authorize! :destroy, @wallet, :message => ""
      @wallet.owners.each do |ownership|
        if @wallet.balance >= 0
          ownership.update_balance_sheets(:value => - @wallet.balance,:current_assets => - @wallet.balance,:cash => - @wallet.balance, :wallets => - @wallet.balance,:item => @wallet,:action => 'destroy')
        else
          ownership.update_balance_sheets(:value => - @wallet.balance,:current_liabilities => @wallet.balance, :wallets => - @wallet.balance,:item => @wallet,:action => 'destroy')
        end
      end
      @wallet.destroy
      redirect_to group_finances_path(@resource)
    end
  end

  private

  def wallet_params
    params.require(:finances_wallet).permit(:name,:description,:starting_balance,:currency,:starting_date,:global_context,:owners_attributes => [:user_id,:global_owner,:equity])
  end

end
