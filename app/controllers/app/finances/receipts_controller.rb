class App::Finances::ReceiptsController < App::AppController

  def index
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
    @wallet = ::Finances::Wallet.find(params[:wallet_id])
    @payments = @wallet.payments.where("value > ?", 0)
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
    @wallet = ::Finances::Wallet.find(params[:wallet_id])
    @payment = ::Finances::Payment.find(params[:id])
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
    @wallet = ::Finances::Wallet.find(params[:wallet_id])
    @payment = ::Finances::Payment.new
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
    @wallet = ::Finances::Wallet.find(params[:wallet_id])

    params[:finances_payment][:value] = BigDecimal.new(params[:finances_payment][:value])
    @payment = @wallet.payments.new(payment_params)
    @payment.currency = @wallet.currency

    @payment.wallet_balance = @wallet.balance + @payment.value
    if @payment.save

      set_adjustments(@payment.value,@wallet.balance)

      @wallet.update_attribute(:balance,@payment.wallet_balance)
      @wallet.owners.each do |ownership|
        ownership.update_balance_sheets(:value => @payment.value,:current_assets => @current_assets,:current_liabilities => @current_liabilities,:cash => @cash, :wallets => @payment.value,:item => @payment,:action => "create")
      end

      flash[:notice] = "Payment registered!"
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def payment_params
    params.require(:finances_payment).permit(:description, :value)
  end

  def set_adjustments(value,balance)
    if balance < 0 && value >= 0
      if balance.abs >= value
        @current_assets = 0
        @current_liabilities = - value
        @cash = 0

      elsif balance.abs < value
        @current_assets = balance + value
        @current_liabilities = balance
        @cash = balance + value

      end
    elsif balance > 0 && value <= 0
      if balance >= value.abs
        @current_assets = value
        @current_liabilities = 0
        @cash = value

      elsif balance < value.abs
        @current_assets = - balance
        @current_liabilities = - (balance + value)
        @cash = - balance

      end
    else
      if value > 0
        @current_assets = value
        @current_liabilities = 0
        @cash = value

      elsif value < 0
        @current_assets = 0
        @current_liabilities = - value
        @cash = 0

      end
    end
  end

end
