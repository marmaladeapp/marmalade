class OwnershipAncestry < ActiveRecord::Base
  belongs_to :ownership
  has_ancestry :cache_depth => true
end
