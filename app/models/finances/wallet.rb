class Finances::Wallet < ActiveRecord::Base
  include HumanizeName
  include Abstractable
  belongs_to :user, :inverse_of => :subscriber_wallets, counter_cache: true

  validates :name, :presence => true

  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  belongs_to :context, polymorphic: true

  has_many :payments, :class_name => 'Finances::Payment'

  has_many :item_wallets, :dependent => :destroy, :foreign_key => 'finances_wallet_id'
  has_many :projects, :through => :item_wallets, :source => :item, :source_type => 'Project'

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  before_destroy do |wallet|
    wallet.payments.where(:ledger_id => nil).destroy_all
    wallet.payments.where.not(:ledger_id => nil).update_all(wallet_id: nil)
  end

  def global_context
    self.context.to_global_id if self.context.present?
  end
  def global_context=(context)
    self.context = GlobalID::Locator.locate context
  end

end
