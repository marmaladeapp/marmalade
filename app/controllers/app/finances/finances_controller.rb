class App::Finances::FinancesController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      authorize! :show, @context, :message => ""
      @balance_sheets = @resource.balance_sheets
      @wallets = @resource.wallets.limit(6)
      @ledgers = @resource.ledgers
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      authorize! :show, @context, :message => ""
      @balance_sheets = @household.balance_sheets
      @wallets = Finances::Wallet.where(:context => @household).limit(6)
      @ledgers = Finances::Ledger.where(:context => @household)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      @context = @group
      authorize! :show, @context, :message => ""
      @balance_sheets = @group.balance_sheets
      @wallets = @group.wallets.limit(6)
      @ledgers = @group.ledgers
    else
      @user_home = current_user.households.first
      @user = current_user
      @groups_and_businesses = []
      @groups_and_businesses += current_user.businesses.to_a
      @groups_and_businesses += current_user.groups.to_a
      if false
        @balance_sheets = current_user.balance_sheets
        @balance_sheets += ::Finances::BalanceSheet.where(:owner => current_user.businesses.to_a)
        @balance_sheets += ::Finances::BalanceSheet.where(:owner => current_user.households.to_a)
        @balance_sheets += ::Finances::BalanceSheet.where(:owner => current_user.groups.to_a)
        @wallets = current_user.wallets
        current_user.businesses.each do |business|
          @wallets += business.wallets
        end
        current_user.households.each do |household|
          @wallets += household.wallets
        end
        current_user.groups.each do |group|
          @wallets += group.wallets
        end
        @ledgers = current_user.ledgers
        current_user.businesses.each do |business|
          @ledgers += business.ledgers
        end
        current_user.households.each do |household|
          @ledgers += household.ledgers
        end
        current_user.groups.each do |group|
          @ledgers += group.ledgers
        end
      end
    end
  end

end
