class ItemWallet < ActiveRecord::Base
  belongs_to :item, polymorphic: true
  belongs_to :wallet, :class_name => 'Finances::Wallet', :foreign_key => 'finances_wallet_id'
end
