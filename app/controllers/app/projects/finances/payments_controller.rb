class App::Projects::Finances::PaymentsController < App::AppController

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @ledger = @project.ledgers.find(params[:receivable_id] ? params[:receivable_id] : params[:debt_id])
    if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
      @ledger.update_fiscal_class
    end
    @payment = ::Finances::Payment.new
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @project = @resource.projects.find(params[:project_id])
      authorize! :update, @project, :message => ""
    end
    @ledger = @project.ledgers.find(params[:receivable_id] ? params[:receivable_id] : params[:debt_id])
    if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
      @ledger.update_fiscal_class
    end

    unless params[:finances_payment][:wallet_id].blank?
      @wallet = @project.wallets.find(params[:finances_payment][:wallet_id])
    end

    if params[:receivable_id]
      params[:finances_payment][:value] = BigDecimal.new(params[:finances_payment][:value])
    elsif params[:debt_id]
      params[:finances_payment][:value] = - BigDecimal.new(params[:finances_payment][:value])
    end

    @payment = @ledger.payments.new(payment_params)
    @payment.currency = @ledger.currency
    @payment.project = @project

    if @wallet
      @payment.wallet_balance = @wallet.balance + @payment.value
    end
    @payment.ledger_balance = @ledger.value - @payment.value

    if ((@ledger.value >= 0 && @payment.ledger_balance >= 0) || (@ledger.value <= 0 && @payment.ledger_balance <= 0)) && @payment.save
      @context.abstracts.create(:item => @ledger, :sub_item => @payment, :user => current_user, :action => 'pay_ledger', :value => @payment.value, :currency => @payment.currency, :project => @project)

      if @ledger.counterledger_id
        @counter_ledger = @project.ledgers.find(@ledger.counterledger_id)
        if @counter_ledger.due_in_full_at < 1.year.from_now && (@counter_ledger.fiscal_class == 'fixed' || @counter_ledger.fiscal_class == 'long_term')
          @counter_ledger.update_fiscal_class
        end
        @counter_payment = @counter_ledger.payments.create(:description => @payment.description,:value => - @payment.value,:ledger_balance => @counter_ledger.value + @payment.value,:currency => @counter_ledger.currency)
        @context.abstracts.create(:item => @counter_ledger, :sub_item => @counter_payment, :user => current_user, :action => 'pay_ledger', :value => @counter_payment.value, :currency => @counter_payment.currency, :project => @project)
      end

      if @wallet
        set_adjustments(@payment.value,@wallet.balance)

        @wallet.update_attribute(:balance,@payment.wallet_balance)
        
        @wallet.owners.each do |ownership|
          ownership.update_balance_sheets(:value => @payment.value,:current_assets => @current_assets,:current_liabilities => @current_liabilities,:cash => @cash, :wallets => @payment.value,:item => @payment,:action => "create")
        end
      end

      @ledger.owners.each do |ownership|
        if @ledger.value > 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @payment.value,:current_assets => - @payment.value,:ledgers_receivable => - @payment.value,:item => @ledger,:action => 'update')
          else
            ownership.update_balance_sheets(:value => - @payment.value,:fixed_assets => - @payment.value,:ledgers_receivable => - @payment.value,:item => @ledger,:action => 'update')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @payment.value,:current_liabilities => @payment.value,:ledgers_debt => @payment.value,:item => @ledger,:action => 'update')
          else
            ownership.update_balance_sheets(:value => - @payment.value,:long_term_liabilities => @payment.value,:ledgers_debt => @payment.value,:item => @ledger,:action => 'update')
          end
        end
      end
      @ledger.update_attribute(:value,@payment.ledger_balance)

      if @counter_payment
        @counter_ledger.owners.each do |ownership|
          if @counter_ledger.value > 0
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_payment.value,:current_assets => - @counter_payment.value,:ledgers_receivable => - @counter_payment.value,:item => @counter_ledger,:action => 'update')
            else
              ownership.update_balance_sheets(:value => - @counter_payment.value,:fixed_assets => - @counter_payment.value,:ledgers_receivable => - @counter_payment.value,:item => @counter_ledger,:action => 'update')
            end
          else
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_payment.value,:current_liabilities => @counter_payment.value,:ledgers_debt => @counter_payment.value,:item => @counter_ledger,:action => 'update')
            else
              ownership.update_balance_sheets(:value => - @counter_payment.value,:long_term_liabilities => @counter_payment.value,:ledgers_debt => @counter_payment.value,:item => @counter_ledger,:action => 'update')
            end
          end
        end
        @counter_ledger.update_attribute(:value,@counter_payment.ledger_balance)
      end

      flash[:notice] = "Payment registered!"
      if params[:resource_id]
        if @ledger.starting_value > 0
          redirect_to resource_project_receivable_path(@resource,@project,@ledger)
        else
          redirect_to resource_project_debt_path(@resource,@project,@ledger)
        end
      elsif params[:user_id]
        if @ledger.starting_value > 0
          redirect_to user_home_project_receivable_path(@user,@project,@ledger)
        else
          redirect_to resource_project_debt_path(@resource,@project,@ledger)
        end
      elsif params[:group_id]
        if @ledger.starting_value > 0
          redirect_to group_project_receivable_path(@context,@project,@ledger)
        else
          redirect_to resource_project_debt_path(@resource,@project,@ledger)
        end
      end
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
    params.require(:finances_payment).permit(:wallet_id, :description, :value)
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
