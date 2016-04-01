module HasModules
  extend ActiveSupport::Concern

  included do
    has_many :messages, :as => :context, :dependent => :destroy, :class_name => 'Messages::Message'

    has_many :address_books, :as => :owner, :dependent => :destroy, :class_name => 'Contacts::AddressBook'
    has_many :calendars, :as => :owner, :dependent => :destroy, :class_name => 'Calendar::Calendar'
    has_many :projects, :as => :owner, :dependent => :destroy, :class_name => 'Project'
    has_many :time_sheets, :as => :owner, :dependent => :destroy, :class_name => 'TimeTracking::TimeSheet'

    has_many :containers, :as => :owner, :dependent => :destroy, :class_name => 'Inventory::Container'

    has_many :balance_sheets, :as => :owner, :dependent => :destroy, :class_name => 'Finances::BalanceSheet'
    has_many :wallets, :through => :ownerships, :source => :item, :source_type => 'Finances::Wallet'
    has_many :ledgers, :through => :ownerships, :source => :item, :source_type => 'Finances::Ledger'

    has_many :contacts, :as => :context, :dependent => :destroy, :class_name => 'Contacts::Contact'
    has_many :contact_profiles, :as => :item, :class_name => 'Contacts::Contact'

    has_many :events, :as => :context, :dependent => :destroy, :class_name => 'Calendar::Event'

    has_many :timers, :as => :context, :dependent => :destroy, :class_name => 'TimeTracking::Timer'

    has_many :inventory_items, :as => :context, :dependent => :destroy, :class_name => 'Inventory::Item'

    has_many :abstracts, :as => :context, :dependent => :destroy


    has_many :contextual_wallets, :as => :context, :dependent => :destroy, :class_name => 'Finances::Wallet'
    has_many :contextual_ledgers, :as => :context, :dependent => :destroy, :class_name => 'Finances::Ledger'

  end

  def net_worth
    balance_sheets.any? ? balance_sheets.last.net_worth : BigDecimal.new(0)
  end
  def total_assets
    balance_sheets.any? ? balance_sheets.last.total_assets : BigDecimal.new(0)
  end
  def current_assets
    balance_sheets.any? ? balance_sheets.last.current_assets : BigDecimal.new(0)
  end
  def fixed_assets
    balance_sheets.any? ? balance_sheets.last.fixed_assets : BigDecimal.new(0)
  end
  def total_liabilities
    balance_sheets.any? ? balance_sheets.last.total_liabilities : BigDecimal.new(0)
  end
  def current_liabilities
    balance_sheets.any? ? balance_sheets.last.current_liabilities : BigDecimal.new(0)
  end
  def long_term_liabilities
    balance_sheets.any? ? balance_sheets.last.long_term_liabilities : BigDecimal.new(0)
  end
  def cash
    balance_sheets.any? ? balance_sheets.last.cash : BigDecimal.new(0)
  end
  def total_ledgers_receivable
    balance_sheets.any? ? balance_sheets.last.total_ledgers_receivable : BigDecimal.new(0)
  end
  def total_ledgers_debt
    balance_sheets.any? ? balance_sheets.last.total_ledgers_debt : BigDecimal.new(0)
  end
  def total_wallets
    balance_sheets.any? ? balance_sheets.last.total_wallets : BigDecimal.new(0)
  end
  def capital_assets
    balance_sheets.any? ? balance_sheets.last.capital_assets : BigDecimal.new(0)
  end
  def inventory
    balance_sheets.any? ? balance_sheets.last.inventory : BigDecimal.new(0)
  end

  private



end
