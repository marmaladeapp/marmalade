class AddMultiCurrencyBoolToOwnershipAncestries < ActiveRecord::Migration
  def change
    add_column :ownership_ancestries, :multi_currency, :boolean, default: false
  end
end
