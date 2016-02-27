class Finances::Wallet < ActiveRecord::Base
  belongs_to :user, :inverse_of => :subscriber_wallets, counter_cache: true

  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  belongs_to :context, polymorphic: true

  has_many :payments, :class_name => 'Finances::Payment'

  accepts_nested_attributes_for :owners

  def global_context
    self.context.to_global_id if self.context.present?
  end
  def global_context=(context)
    self.context = GlobalID::Locator.locate context
  end

end
