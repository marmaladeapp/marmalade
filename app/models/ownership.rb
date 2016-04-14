class Ownership < ActiveRecord::Base
  include Abstractable
  default_scope { order(created_at: :asc) }

  belongs_to :user, :inverse_of => :subscriber_ownerships

  belongs_to :owner, polymorphic: true
  belongs_to :item, polymorphic: true

  has_many :ancestries, :dependent => :destroy, :class_name => "OwnershipAncestry"

  validates_presence_of :owner, unless: Proc.new { |ownership| item.present? }
  validates_presence_of :item, unless: Proc.new { |ownership| owner.present? }

  after_create :create_ancestry
  after_destroy :destroy_orphans

  def global_owner
    self.owner.to_global_id if self.owner.present?
  end
  def global_owner=(owner)
    self.owner = GlobalID::Locator.locate owner
  end

  def update_balance_sheets(value:0, current_assets:0, fixed_assets:0, current_liabilities:0, long_term_liabilities:0, cash:0, ledgers_receivable:0, ledgers_debt:0, wallets:0, capital_assets:0, inventory:0, item:nil, action:nil)
    @unique_owners = []
    instantiating_item = item
    @value = value
    @current_assets = current_assets
    @fixed_assets = fixed_assets
    @current_liabilities = current_liabilities
    @long_term_liabilities = long_term_liabilities
    @cash = cash
    @ledgers_receivable = ledgers_receivable
    @ledgers_debt = ledgers_debt
    @wallets = wallets
    @capital_assets = capital_assets
    @inventory = inventory

    Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))

    self.ancestries.each do |ancestry| # ownership.object_ancestry
      @business_types = []
      ancestry.path.reverse.each do |ancestor| # object_ancestry.object_ancestries including self
        if ancestor.multi_currency && ancestor.last_converted < Money.default_bank.rates_updated_at.to_datetime
          ancestor.update_conversions
        end
        ownership = ancestor.ownership
        if !@unique_owners.include?(ownership)
          item = ownership.item
          item_currency = (["Wallet","Ledger"].include?(item.class.name) ? item.currency : item.currency)
          owner = ownership.owner
          owner_currency = owner.currency
          equity = ownership.equity
          net_worth = owner.net_worth

          @value = equity.percent_of(@value.convert_currency(item_currency,owner_currency))
          @current_assets = equity.percent_of(@current_assets.convert_currency(item_currency,owner_currency))
          @fixed_assets = equity.percent_of(@fixed_assets.convert_currency(item_currency,owner_currency))
          @current_liabilities = equity.percent_of(@current_liabilities.convert_currency(item_currency,owner_currency))
          @long_term_liabilities = equity.percent_of(@long_term_liabilities.convert_currency(item_currency,owner_currency))
          @cash = equity.percent_of(@cash.convert_currency(item_currency,owner_currency))
          @ledgers_receivable = equity.percent_of(@ledgers_receivable.convert_currency(item_currency,owner_currency))
          @ledgers_debt = equity.percent_of(@ledgers_debt.convert_currency(item_currency,owner_currency))
          @wallets = equity.percent_of(@wallets.convert_currency(item_currency,owner_currency))
          @capital_assets = equity.percent_of(@capital_assets.convert_currency(item_currency,owner_currency))
          @inventory = equity.percent_of(@inventory.convert_currency(item_currency,owner_currency))

          if item.class.name == "Business"
            @business_types << item.business_type
          end

          if (["LimitedPartnership","LimitedLiabilityPartnership","LimitedCompany"] & @business_types).empty?
            if item == instantiating_item || (owner.class.name == "Household" && self.owner.class.name == "User")
              owner.balance_sheets.create(:current_assets => owner.current_assets + @current_assets, :fixed_assets => owner.fixed_assets + @fixed_assets, :current_liabilities => owner.current_liabilities + @current_liabilities, :long_term_liabilities => owner.long_term_liabilities + @long_term_liabilities, :cash => owner.cash + @cash, :currency => owner_currency, :total_ledgers_receivable => owner.total_ledgers_receivable + @ledgers_receivable, :total_ledgers_debt => owner.total_ledgers_debt + @ledgers_debt, :total_wallets => owner.total_wallets + @wallets, :capital_assets => owner.capital_assets + @capital_assets, :inventory => owner.inventory + @inventory, :item => instantiating_item, :action => action)
            else
              owner.balance_sheets.create(:current_assets => owner.current_assets + @current_assets, :fixed_assets => owner.fixed_assets + @fixed_assets, :current_liabilities => owner.current_liabilities + @current_liabilities, :long_term_liabilities => owner.long_term_liabilities + @long_term_liabilities, :cash => owner.cash + @cash, :currency => owner_currency, :total_ledgers_receivable => owner.total_ledgers_receivable, :total_ledgers_debt => owner.total_ledgers_debt, :total_wallets => owner.total_wallets, :capital_assets => owner.capital_assets + @capital_assets, :inventory => owner.inventory + @inventory, :item => instantiating_item, :action => action)
            end
          elsif (["LimitedLiabilityPartnership","LimitedCompany"] & @business_types).empty?
            assets = @current_assets + @fixed_assets
            liabilities = @current_liabilities + @long_term_liabilities
            owner.balance_sheets.create(:current_assets => owner.current_assets, :fixed_assets => owner.fixed_assets + assets, :current_liabilities => owner.current_liabilities, :long_term_liabilities => owner.long_term_liabilities + liabilities, :cash => owner.cash, :currency => owner_currency, :item => instantiating_item, :action => action, :total_ledgers_receivable => owner.total_ledgers_receivable, :total_ledgers_debt => owner.total_ledgers_debt, :total_wallets => owner.total_wallets, :capital_assets => owner.capital_assets + assets, :inventory => owner.inventory)
          elsif (["LimitedLiabilityPartnership","LimitedCompany"] & @business_types).any?
            assets = @value
            owner.balance_sheets.create(:current_assets => owner.current_assets, :fixed_assets => owner.fixed_assets + assets, :current_liabilities => owner.current_liabilities, :long_term_liabilities => owner.long_term_liabilities, :cash => owner.cash, :currency => owner_currency, :item => instantiating_item, :action => action, :total_ledgers_receivable => owner.total_ledgers_receivable, :total_ledgers_debt => owner.total_ledgers_debt, :total_wallets => owner.total_wallets, :capital_assets => owner.capital_assets + assets, :inventory => owner.inventory)
          end

          if owner.class.name == "Business" && ["LimitedCompany","LimitedLiabilityPartnership"].include?(owner.business_type)
            if (@value < 0 && (net_worth + @value) >= 0) || (@value > 0 && net_worth >= 0)
              @value = @value
            elsif (@value < 0 && net_worth > 0 && (net_worth + @value < 0))
              @value = - net_worth
            elsif (@value > 0 && net_worth < 0 && (net_worth + @value > 0))
              @value = net_worth + @value
            else
              @value = 0
            end
          end
          @unique_owners << ownership
        end
      end
    end
  end

  private

  def create_ancestry
    if (["Contacts::Contact","Calendar::Event","TimeTracking::Timer"] & item.class.name.lines.to_a).empty?
      if owner.owners.any?
        owner.owners.each do |ownership|
          ownership.ancestries.each do |ancestry|
            @ancestry = ancestry.children.create(:ownership => self, :item_class => owner.class.name, :multi_currency => (owner.currency == item.currency ? false : true), :last_converted => DateTime.now)
          end
        end
      else
        @ancestry = OwnershipAncestry.create(:ownership => self, :item_class => owner.class.name, :multi_currency => (owner.currency == item.currency ? false : true), :last_converted => DateTime.now)
      end
      if item.ownerships.any?
        item.ownerships.each do |ownership|
          ownership.ancestries.each do |ancestry|
            @descendant = @ancestry
            ancestry.subtree.each do |descendant|
              if ancestry.is_root?
                descendant.update_attributes(:ancestry => (@ancestry.ancestry.blank? ? "" : "#{@ancestry.ancestry}/") + "#{@ancestry.id}" + (descendant.ancestry.blank? ? "" : "/" + descendant.ancestry), :ancestry_depth => descendant.ancestry_depth + @ancestry.ancestry_depth + 1)
              else
                @descendant = @descendant.children.create(:ownership => descendant.ownership, :item_class => descendant.item_class, :multi_currency => (descendant.ownership.owner.currency == descendant.ownership.item.currency ? false : true), :last_converted => DateTime.now)
              end
            end
          end
        end
      end
    end
  end

  def destroy_orphans
    if self.owner.class.name == "User"
      unless Ownership.where(:owner => self.owner, :user => self.user).any? || Membership.where(:member => self.owner, :user => self.user).any?
        unless self.user == self.owner
          if collab = Collaborator.find_by(:user => self.user, :collaborator => self.owner)
            collab.destroy
          end
        end
      end
    end
    if self.item.class.name == "Finances::Wallet" || self.item.class.name == "Finances::Ledger" || self.item.class.name == "Inventory::Item"
      self.item.destroy if self.item.owners.empty?
    end
  end

end
