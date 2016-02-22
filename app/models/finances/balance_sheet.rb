class Finances::BalanceSheet < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :item, polymorphic: true

  validates :total_assets, :current_assets, :fixed_assets, :total_liabilities, :current_liabilities, :long_term_liabilities, :cash, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }

  before_validation :update_balances

  private

  def update_balances
    # note: we've had to move owner.total_assets and owner.total_liabilities out of this method.
    # It had to be placed in the call to create the balance_sheet, otherwise we wound up with infinite loops OR...
    # ...a lack of awareness for the current values - while everything else is initialized at 0.
    self.total_assets = self.current_assets + self.fixed_assets
    self.total_liabilities = self.current_liabilities + self.long_term_liabilities
    self.net_worth = self.total_assets - self.total_liabilities
  end

end
