class OwnershipAncestry < ActiveRecord::Base
  belongs_to :ownership
  has_ancestry :cache_depth => true

  def update_conversions

    old_rate = BigDecimal.new(1).old_conversion(ownership.item.currency,ownership.owner.currency)
    new_rate = BigDecimal.new(1).convert_currency(ownership.item.currency,ownership.owner.currency)
    adjustment = ((new_rate - old_rate) / old_rate)

    case ownership.item.class.name
    when "User"
      ownership.update_balance_sheets(:value => adjustment * ownership.item.net_worth,:current_assets => adjustment * ownership.item.current_assets,:fixed_assets => adjustment * ownership.item.fixed_assets,:current_liabilities => adjustment * ownership.item.current_liabilities,:long_term_liabilities => adjustment * ownership.item.long_term_liabilities,:cash => adjustment * ownership.item.cash,:ledgers_receivable => adjustment * ownership.item.total_ledgers_receivable,:ledgers_debt => adjustment * ownership.item.total_ledgers_debt,:wallets => adjustment * ownership.item.total_wallets,:capital_assets => adjustment * ownership.item.capital_assets,:inventory => adjustment * ownership.item.inventory,:item => ownership.item,:action => 'update')

    when "Business"
      ownership.update_balance_sheets(:value => adjustment * ownership.item.net_worth,:current_assets => adjustment * ownership.item.current_assets,:fixed_assets => adjustment * ownership.item.fixed_assets,:current_liabilities => adjustment * ownership.item.current_liabilities,:long_term_liabilities => adjustment * ownership.item.long_term_liabilities,:cash => adjustment * ownership.item.cash,:ledgers_receivable => adjustment * ownership.item.total_ledgers_receivable,:ledgers_debt => adjustment * ownership.item.total_ledgers_debt,:wallets => adjustment * ownership.item.total_wallets,:capital_assets => adjustment * ownership.item.capital_assets,:inventory => adjustment * ownership.item.inventory,:item => ownership.item,:action => 'update')

    when "Inventory::Item"
      if ownership.item.saleable
        ownership.update_balance_sheets(:value => adjustment * ownership.item.value,:current_assets => adjustment * ownership.item.value,:inventory => adjustment * ownership.item.value,:item => ownership.item,:action => 'update')
      elsif !ownership.item.consumable
        ownership.update_balance_sheets(:value => adjustment * ownership.item.value,:fixed_assets => adjustment * ownership.item.value,:capital_assets => adjustment * ownership.item.value,:item => ownership.item,:action => 'update')
      end

    when "Finances::Ledger"
      if ownership.item.value >= 0
        if ownership.item.due_in_full_at < 1.year.from_now
          ownership.update_balance_sheets(:value => adjustment * ownership.item.value,:current_assets => adjustment * ownership.item.value,:ledgers_receivable => adjustment * ownership.item.value,:item => ownership.item,:action => 'update')
        else
          ownership.update_balance_sheets(:value => adjustment * ownership.item.value,:fixed_assets => adjustment * ownership.item.value,:ledgers_receivable => adjustment * ownership.item.value,:item => ownership.item,:action => 'update')
        end
      else
        if ownership.item.due_in_full_at < 1.year.from_now
          ownership.update_balance_sheets(:value => adjustment * ownership.item.value,:current_liabilities => - adjustment * ownership.item.value,:ledgers_debt => - adjustment * ownership.item.value,:item => ownership.item,:action => 'update')
        else
          ownership.update_balance_sheets(:value => adjustment * ownership.item.value,:long_term_liabilities => - adjustment * ownership.item.value,:ledgers_debt => - adjustment * ownership.item.value,:item => ownership.item,:action => 'update')
        end
      end

    when "Finances::Wallet"
      if ownership.item.balance >= 0
        ownership.update_balance_sheets(:value => adjustment * ownership.item.balance,:current_assets => adjustment * ownership.item.balance,:cash => adjustment * ownership.item.balance, :wallets => adjustment * ownership.item.balance,:item => ownership.item,:action => 'update')
      else
        ownership.update_balance_sheets(:value => adjustment * ownership.item.balance,:current_liabilities => - adjustment * ownership.item.balance, :wallets => adjustment * ownership.item.balance,:item => ownership.item,:action => 'update')
      end
    end
    update_attribute(:last_converted, DateTime.now)
  end
end
