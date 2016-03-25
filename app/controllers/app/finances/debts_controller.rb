class App::Finances::DebtsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledgers = @resource.ledgers.where("starting_value < ?", 0)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledgers = @resource.ledgers.where("starting_value < ?", 0)
      @resource.ownerships.each do |ownership|
        @ledgers += ownership.item.ledgers.where("starting_value < ?", 0)
      end
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledgers = @resource.ledgers.where("starting_value < ?", 0)
    else
      @ledgers = current_user.ledgers.where("starting_value < ?", 0)
      current_user.businesses.each do |business|
        @ledgers += business.ledgers.where("starting_value < ?", 0)
      end
      current_user.households.each do |household|
        @ledgers += household.ledgers.where("starting_value < ?", 0)
      end
      current_user.groups.each do |group|
        @ledgers += group.ledgers.where("starting_value < ?", 0)
      end
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
    @ledger = ::Finances::Ledger.find(params[:id])
    if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
      @ledger.update_fiscal_class
    end
    authorize! :show, @ledger, :message => ""
    @payments = @ledger.payments.order(created_at: :desc).page(params[:page]) #.per(2)
    if @payments.last == @ledger.payments.first || @payments.empty
      @payments << ::Finances::Payment.new(:description => 'Starting Balance', :value => 0, :ledger_balance => @ledger.starting_value, :created_at => @ledger.created_at, :currency => @ledger.currency)
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
    @ledger = ::Finances::Ledger.new
    if @resource.class.name == "Household"
      @ownerships = []
      @resource.members.each do |member|
        @ownerships << Ownership.new(:owner => member, :item => @ledger, :equity => BigDecimal.new(100) / @resource.members.count, :user_id => @resource.user.id)
      end
    else
      @ownerships = []
      @ownerships << Ownership.new(:owner => @resource, :item => @ledger, :equity => BigDecimal.new(100), :user_id => @resource.class.name == "User" ? @resource.id : @resource.user.id)
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
    params[:finances_ledger][:starting_value] = - BigDecimal.new(params[:finances_ledger][:starting_value])
    @ledger = ::Finances::Ledger.new(ledger_params)
    @ledger.value = @ledger.starting_value
    @ledger.context = @context
    if @ledger.due_in_full_at < 1.year.from_now
      @ledger.fiscal_class = 'current'
    else
      @ledger.fiscal_class = 'long_term'
    end
    authorize! :create, @ledger, :message => ""
    if @ledger.save
      @context.abstracts.create(:item => @ledger, :user => current_user, :action => 'create')

      if @ledger.counterparty
        case @ledger.counterparty.class.name
        when "User", "Business"
          @counter_ledger = ::Finances::Ledger.create(:name => @ledger.name, :description => @ledger.description, :value => - @ledger.value, :starting_value => - @ledger.starting_value, :currency => @ledger.currency, :due_in_full_at => @ledger.due_in_full_at, :counterparty => @ledger.context ? @ledger.context : @ledger.owners.first, :context => @ledger.counterparty, :counterledger_id => @ledger.id, :owners_attributes => [:owner => @ledger.counterparty, :user_id => @ledger.counterparty.user_id,:equity => BigDecimal.new(100)])
          @counter_ledger.context.abstracts.create(:item => @counter_ledger, :user => current_user, :action => 'create')
        when "Household"
          @counter_ledger = ::Finances::Ledger.create(:name => @ledger.name, :description => @ledger.description, :value => - @ledger.value, :starting_value => - @ledger.starting_value, :currency => @ledger.currency, :due_in_full_at => @ledger.due_in_full_at, :counterparty => @ledger.context ? @ledger.context : @ledger.owners.first, :context => @ledger.counterparty, :counterledger_id => @ledger.id)
          @counter_ledger.context.abstracts.create(:item => @counter_ledger, :user => current_user, :action => 'create')
          @ledger.counterparty.members.each do |member|
            member.ownerships.create(:item => @counter_ledger,:user_id => @ledger.counterparty.user_id,:equity => BigDecimal.new(100) / @ledger.counterparty.members.count)
          end
        end
        @ledger.update_attributes(:counterledger_id => @counter_ledger.id)
      end

      @ledger.owners.each do |ownership|
        if @ledger.value >= 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => @ledger.value,:current_assets => @ledger.value,:ledgers_receivable => @ledger.value,:item => @ledger,:action => 'create')
          else
            ownership.update_balance_sheets(:value => @ledger.value,:fixed_assets => @ledger.value,:ledgers_receivable => @ledger.value,:item => @ledger,:action => 'create')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => @ledger.value,:current_liabilities => - @ledger.value,:ledgers_debt => - @ledger.value,:item => @ledger,:action => 'create')
          else
            ownership.update_balance_sheets(:value => @ledger.value,:long_term_liabilities => - @ledger.value,:ledgers_debt => - @ledger.value,:item => @ledger,:action => 'create')
          end
        end
      end

      if @counter_ledger
        @counter_ledger.owners.each do |ownership|
          if @counter_ledger.value >= 0
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => @counter_ledger.value,:current_assets => @counter_ledger.value,:ledgers_receivable => @counter_ledger.value,:item => @counter_ledger,:action => 'create')
            else
              ownership.update_balance_sheets(:value => @counter_ledger.value,:fixed_assets => @counter_ledger.value,:ledgers_receivable => @counter_ledger.value,:item => @counter_ledger,:action => 'create')
            end
          else
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => @counter_ledger.value,:current_liabilities => - @counter_ledger.value,:ledgers_debt => - @counter_ledger.value,:item => @counter_ledger,:action => 'create')
            else
              ownership.update_balance_sheets(:value => @counter_ledger.value,:long_term_liabilities => - @counter_ledger.value,:ledgers_debt => - @counter_ledger.value,:item => @counter_ledger,:action => 'create')
            end
          end
        end
      end

      if params[:resource_id]
        redirect_to resource_debt_path(@resource,@ledger)
      elsif params[:user_id]
        redirect_to user_home_debt_path(@user,@ledger)
      elsif params[:group_id]
        redirect_to group_debt_path(@context,@ledger)
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
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :edit, @ledger, :message => ""
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :edit, @ledger, :message => ""
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :edit, @ledger, :message => ""
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :update, @ledger, :message => ""
      if @ledger.update_attributes(ledger_params)
        redirect_to resource_debt_path(@resource,@ledger)
      else
        render 'edit'
      end
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :update, @ledger, :message => ""
      if @ledger.update_attributes(ledger_params)
        redirect_to user_home_debt_path(@user,@ledger)
      else
        render 'edit'
      end
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :update, @ledger, :message => ""
      if @ledger.update_attributes(ledger_params)
        redirect_to group_debt_path(@resource,@ledger)
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
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :destroy, @ledger, :message => ""

      @ledger.owners.each do |ownership|
        if @ledger.value >= 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @ledger.value,:current_assets => - @ledger.value,:ledgers_receivable => - @ledger.value,:item => @ledger,:action => 'destroy')
          else
            ownership.update_balance_sheets(:value => - @ledger.value,:fixed_assets => - @ledger.value,:ledgers_receivable => - @ledger.value,:item => @ledger,:action => 'destroy')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @ledger.value,:current_liabilities => @ledger.value,:ledgers_debt => @ledger.value,:item => @ledger,:action => 'destroy')
          else
            ownership.update_balance_sheets(:value => - @ledger.value,:long_term_liabilities => @ledger.value,:ledgers_debt => @ledger.value,:item => @ledger,:action => 'destroy')
          end
        end
      end

      if @ledger.counterledger_id
        @counter_ledger = ::Finances::Ledger.find(@ledger.counterledger_id)
        if @counter_ledger.due_in_full_at < 1.year.from_now && (@counter_ledger.fiscal_class == 'fixed' || @counter_ledger.fiscal_class == 'long_term')
          @counter_ledger.update_fiscal_class
        end
        @counter_ledger.owners.each do |ownership|
          if @counter_ledger.value >= 0
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:current_assets => - @counter_ledger.value,:ledgers_receivable => - @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            else
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:fixed_assets => - @counter_ledger.value,:ledgers_receivable => - @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            end
          else
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:current_liabilities => @counter_ledger.value,:ledgers_debt => @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            else
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:long_term_liabilities => @counter_ledger.value,:ledgers_debt => @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            end
          end
        end
        @counter_ledger.destroy
      end

      @ledger.destroy
      redirect_to resource_debts_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :destroy, @ledger, :message => ""

      @ledger.owners.each do |ownership|
        if @ledger.value >= 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @ledger.value,:current_assets => - @ledger.value,:ledgers_receivable => - @ledger.value,:item => @ledger,:action => 'destroy')
          else
            ownership.update_balance_sheets(:value => - @ledger.value,:fixed_assets => - @ledger.value,:ledgers_receivable => - @ledger.value,:item => @ledger,:action => 'destroy')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @ledger.value,:current_liabilities => @ledger.value,:ledgers_debt => @ledger.value,:item => @ledger,:action => 'destroy')
          else
            ownership.update_balance_sheets(:value => - @ledger.value,:long_term_liabilities => @ledger.value,:ledgers_debt => @ledger.value,:item => @ledger,:action => 'destroy')
          end
        end
      end

      if @ledger.counterledger_id
        @counter_ledger = ::Finances::Ledger.find(@ledger.counterledger_id)
        if @counter_ledger.due_in_full_at < 1.year.from_now && (@counter_ledger.fiscal_class == 'fixed' || @counter_ledger.fiscal_class == 'long_term')
          @counter_ledger.update_fiscal_class
        end
        @counter_ledger.owners.each do |ownership|
          if @counter_ledger.value >= 0
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:current_assets => - @counter_ledger.value,:ledgers_receivable => - @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            else
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:fixed_assets => - @counter_ledger.value,:ledgers_receivable => - @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            end
          else
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:current_liabilities => @counter_ledger.value,:ledgers_debt => @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            else
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:long_term_liabilities => @counter_ledger.value,:ledgers_debt => @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            end
          end
        end
        @counter_ledger.destroy
      end

      @ledger.destroy
      redirect_to user_home_debts_path(@user)
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @context, :message => ""
      @ledger = ::Finances::Ledger.find(params[:id])
      if @ledger.due_in_full_at < 1.year.from_now && (@ledger.fiscal_class == 'fixed' || @ledger.fiscal_class == 'long_term')
        @ledger.update_fiscal_class
      end
      authorize! :destroy, @ledger, :message => ""

      @ledger.owners.each do |ownership|
        if @ledger.value >= 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @ledger.value,:current_assets => - @ledger.value,:ledgers_receivable => - @ledger.value,:item => @ledger,:action => 'destroy')
          else
            ownership.update_balance_sheets(:value => - @ledger.value,:fixed_assets => - @ledger.value,:ledgers_receivable => - @ledger.value,:item => @ledger,:action => 'destroy')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @ledger.value,:current_liabilities => @ledger.value,:ledgers_debt => @ledger.value,:item => @ledger,:action => 'destroy')
          else
            ownership.update_balance_sheets(:value => - @ledger.value,:long_term_liabilities => @ledger.value,:ledgers_debt => @ledger.value,:item => @ledger,:action => 'destroy')
          end
        end
      end

      if @ledger.counterledger_id
        @counter_ledger = ::Finances::Ledger.find(@ledger.counterledger_id)
        if @counter_ledger.due_in_full_at < 1.year.from_now && (@counter_ledger.fiscal_class == 'fixed' || @counter_ledger.fiscal_class == 'long_term')
          @counter_ledger.update_fiscal_class
        end
        @counter_ledger.owners.each do |ownership|
          if @counter_ledger.value >= 0
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:current_assets => - @counter_ledger.value,:ledgers_receivable => - @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            else
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:fixed_assets => - @counter_ledger.value,:ledgers_receivable => - @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            end
          else
            if @counter_ledger.due_in_full_at < 1.year.from_now
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:current_liabilities => @counter_ledger.value,:ledgers_debt => @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            else
              ownership.update_balance_sheets(:value => - @counter_ledger.value,:long_term_liabilities => @counter_ledger.value,:ledgers_debt => @counter_ledger.value,:item => @counter_ledger,:action => 'destroy')
            end
          end
        end
        @counter_ledger.destroy
      end

      @ledger.destroy
      redirect_to group_debts_path(@resource)
    end
  end

  private

  def ledger_params
    params.require(:finances_ledger).permit(:name, :description, :starting_value, :currency, :"due_in_full_at(1i)", :"due_in_full_at(2i)", :"due_in_full_at(3i)", :global_counterparty, :global_context, :owners_attributes => [:user_id,:global_owner,:equity])
  end

end
