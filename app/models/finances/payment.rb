class Finances::Payment < ActiveRecord::Base
  include Abstractable
  default_scope { order(created_at: :desc) }
  belongs_to :wallet
  belongs_to :ledger
  belongs_to :project

  validates :value, :numericality => {:other_than => 0}
end
