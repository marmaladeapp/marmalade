class Finances::Ledger < ActiveRecord::Base
  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  accepts_nested_attributes_for :owners
end
