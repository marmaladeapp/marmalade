class App::Finances::FinancesController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @balance_sheets = @resource.balance_sheets
      @wallets = @resource.wallets
      @ledgers = @resource.ledgers
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      @balance_sheets = @household.balance_sheets
      @wallets = Finances::Wallet.where(:context => @household)
      @ledgers = Finances::Ledger.where(:context => @household)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      @context = @group
      @balance_sheets = @group.balance_sheets
      @wallets = @group.wallets
      @ledgers = @group.ledgers
    else
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
