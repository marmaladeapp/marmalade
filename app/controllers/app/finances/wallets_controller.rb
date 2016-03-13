class App::Finances::WalletsController < App::AppController

  def index
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    @wallet = ::Finances::Wallet.find(params[:id])
    @payments = @wallet.payments.order(created_at: :desc).page(params[:page]) #.per(2)
    if @payments.last == @wallet.payments.first || @payments.empty?
      @payments << ::Finances::Payment.new(:description => 'Starting Balance', :value => 0, :wallet_balance => @wallet.starting_balance, :created_at => @wallet.created_at, :currency => @wallet.currency)
    end
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
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
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    params[:finances_wallet][:starting_balance] = BigDecimal.new(params[:finances_wallet][:starting_balance])
    @wallet = ::Finances::Wallet.new(wallet_params)
    @wallet.balance = @wallet.starting_balance
    @wallet.user = @resource.class.name == "User" ? current_user : @resource.user
    @wallet.context = @context
    if @wallet.save
      @context.abstracts.create(:item => @wallet, :user => current_user, :action => 'create')
      @wallet.owners.each do |ownership|
        if @wallet.balance >= 0
          ownership.update_balance_sheets(:value => @wallet.balance,:current_assets => @wallet.balance,:cash => @wallet.balance, :wallets => @wallet.balance,:item => @wallet,:action => 'create')
        else
          ownership.update_balance_sheets(:value => @wallet.balance,:current_liabilities => - @wallet.balance, :wallets => @wallet.balance,:item => @wallet,:action => 'create')
        end
      end
      redirect_to root_path
    else
      render 'new'
    end
  end

  private

  def wallet_params
    params.require(:finances_wallet).permit(:name,:description,:starting_balance,:currency,:starting_date,:global_context,:owners_attributes => [:user_id,:global_owner,:equity])
  end

end
