desc "This task is called by the Heroku scheduler add-on"

task :update_exchange_rates_and_currencies => :environment do
  bank = Money.default_bank
  if !bank.rates_updated_at || bank.rates_updated_at < Time.now - 1.days
    $redis.rename("exchange_rates","previous_rates")
    $redis.set("exchange_rates",Money.default_bank.save_rates_to_s)
    # $redis.set("exchange_rates_#{Date.today.to_formatted_s(:db)}",Money.default_bank.save_rates_to_s)
    # Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))

    supported_currencies = []
    Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))
    Money.default_bank.rates.keys.each do |r|
      supported_currencies << r.match(/EUR_TO_([A-Z]+)/).captures.first
    end
    $redis.del("supported_currencies")
    $redis.sadd("supported_currencies",supported_currencies)
    # $redis.sadd("supported_currencies_#{Date.today.to_formatted_s(:db)}",supported_currencies)
    # $redis.smembers("supported_currencies")
  end
end

task :update_ledgers => :environment do
  adjustment * @ownership.items = Finances::Ledger.where(:fiscal_class => ['long_term','fixed']).where("due_in_full_at < ?", 1.year.from_now)
  adjustment * @ownership.items.each do |ledger|
    ledger.update_fiscal_class
  end
end

task :update_conversions => :environment do
  Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))
  @ancestries = OwnershipAncestry.order(ancestry_depth: :asc).where(:multi_currency => true).where("last_converted < ?", Money.default_bank.rates_updated_at.to_datetime)
  @ancestries.each do |ancestry|
    @ownership = ancestry.ownership

    old_rate = BigDecimal.new(1).old_conversion(@ownership.item.currency,@ownership.owner.currency)
    new_rate = BigDecimal.new(1).convert_currency(@ownership.item.currency,@ownership.owner.currency)
    adjustment = ((new_rate - old_rate) / old_rate)

    case @ownership.item.class.name
    when "User"
      @ownership.update_balance_sheets(:value => adjustment * @ownership.item.net_worth,:current_assets => adjustment * @ownership.item.current_assets,:fixed_assets => adjustment * @ownership.item.fixed_assets,:current_liabilities => adjustment * @ownership.item.current_liabilities,:long_term_liabilities => adjustment * @ownership.item.long_term_liabilities,:cash => adjustment * @ownership.item.cash,:ledgers_receivable => adjustment * @ownership.item.total_ledgers_receivable,:ledgers_debt => adjustment * @ownership.item.total_ledgers_debt,:wallets => adjustment * @ownership.item.total_wallets,:capital_assets => adjustment * @ownership.item.capital_assets,:inventory => adjustment * @ownership.item.inventory,:item => @ownership.item,:action => 'update')

    when "Business"
      @ownership.update_balance_sheets(:value => adjustment * @ownership.item.net_worth,:current_assets => adjustment * @ownership.item.current_assets,:fixed_assets => adjustment * @ownership.item.fixed_assets,:current_liabilities => adjustment * @ownership.item.current_liabilities,:long_term_liabilities => adjustment * @ownership.item.long_term_liabilities,:cash => adjustment * @ownership.item.cash,:ledgers_receivable => adjustment * @ownership.item.total_ledgers_receivable,:ledgers_debt => adjustment * @ownership.item.total_ledgers_debt,:wallets => adjustment * @ownership.item.total_wallets,:capital_assets => adjustment * @ownership.item.capital_assets,:inventory => adjustment * @ownership.item.inventory,:item => @ownership.item,:action => 'update')

    when "Inventory::Item"
      if @ownership.item.saleable
        @ownership.update_balance_sheets(:value => adjustment * @ownership.item.value,:current_assets => adjustment * @ownership.item.value,:inventory => adjustment * @ownership.item.value,:item => @ownership.item,:action => 'update')
      elsif !@ownership.item.consumable
        @ownership.update_balance_sheets(:value => adjustment * @ownership.item.value,:fixed_assets => adjustment * @ownership.item.value,:capital_assets => adjustment * @ownership.item.value,:item => @ownership.item,:action => 'update')
      end

    when "Finances::Ledger"
      if @ownership.item.value >= 0
        if @ownership.item.due_in_full_at < 1.year.from_now
          @ownership.update_balance_sheets(:value => adjustment * @ownership.item.value,:current_assets => adjustment * @ownership.item.value,:ledgers_receivable => adjustment * @ownership.item.value,:item => @ownership.item,:action => 'update')
        else
          @ownership.update_balance_sheets(:value => adjustment * @ownership.item.value,:fixed_assets => adjustment * @ownership.item.value,:ledgers_receivable => adjustment * @ownership.item.value,:item => @ownership.item,:action => 'update')
        end
      else
        if @ownership.item.due_in_full_at < 1.year.from_now
          @ownership.update_balance_sheets(:value => adjustment * @ownership.item.value,:current_liabilities => - adjustment * @ownership.item.value,:ledgers_debt => - adjustment * @ownership.item.value,:item => @ownership.item,:action => 'update')
        else
          @ownership.update_balance_sheets(:value => adjustment * @ownership.item.value,:long_term_liabilities => - adjustment * @ownership.item.value,:ledgers_debt => - adjustment * @ownership.item.value,:item => @ownership.item,:action => 'update')
        end
      end

    when "Finances::Wallet"
      if @ownership.item.balance >= 0
        @ownership.update_balance_sheets(:value => adjustment * @ownership.item.balance,:current_assets => adjustment * @ownership.item.balance,:cash => adjustment * @ownership.item.balance, :wallets => adjustment * @ownership.item.balance,:item => @ownership.item,:action => 'update')
      else
        @ownership.update_balance_sheets(:value => adjustment * @ownership.item.balance,:current_liabilities => - adjustment * @ownership.item.balance, :wallets => adjustment * @ownership.item.balance,:item => @ownership.item,:action => 'update')
      end
    end
    ancestry.update_attribute(:last_converted, DateTime.now)
  end
end