class Finances::Payment < ActiveRecord::Base
  belongs_to :wallet
  belongs_to :ledger
end
