class Finances::Ledger < ActiveRecord::Base
  include Abstractable
  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  belongs_to :context, polymorphic: true
  belongs_to :counterparty, polymorphic: true

  has_one :counterledger, :as => :counterledger, :class_name => 'Finances::Ledger'

  has_many :payments, :class_name => 'Finances::Payment'

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  def global_context
    self.context.to_global_id if self.context.present?
  end
  def global_context=(context)
    self.context = GlobalID::Locator.locate context
  end

  def global_counterparty
    self.counterparty.to_global_id if self.counterparty.present?
  end
  def global_counterparty=(counterparty)
    self.counterparty = GlobalID::Locator.locate counterparty
  end

end
