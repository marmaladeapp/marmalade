class Inventory::Container < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user
end
