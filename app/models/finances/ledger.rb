class Finances::Ledger < ActiveRecord::Base
  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  belongs_to :context, polymorphic: true
  belongs_to :counterparty, polymorphic: true

  accepts_nested_attributes_for :owners

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
