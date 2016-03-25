class Finances::Ledger < ActiveRecord::Base
  include Abstractable
  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  belongs_to :context, polymorphic: true
  belongs_to :counterparty, polymorphic: true

  belongs_to :project

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

  def update_fiscal_class
    owners.each do |ownership|
      if value >= 0
        ownership.update_balance_sheets(:current_assets => value,:fixed_assets => - value,:item => self,:action => 'update')
      else
        ownership.update_balance_sheets(:current_liabilities => - value,:long_term_liabilities => value,:item => self,:action => 'update')
      end
    end
    update_attributes(:fiscal_class => 'current')
  end

end
