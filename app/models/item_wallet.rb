class ItemWallet < ActiveRecord::Base
  validates :finances_wallet_id, :presence => true
  belongs_to :item, polymorphic: true
  belongs_to :wallet, :class_name => 'Finances::Wallet', :foreign_key => 'finances_wallet_id'
end
