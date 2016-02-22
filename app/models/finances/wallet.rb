class Finances::Wallet < ActiveRecord::Base
  belongs_to :user, :inverse_of => :subscriber_wallets, counter_cache: true

  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  accepts_nested_attributes_for :owners

end
