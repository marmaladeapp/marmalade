class Household < ActiveRecord::Base
  include HumanizeName

  belongs_to :subscriber, :class_name => 'User'
  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :items, :through => :ownerships
  has_many :users, :through => :ownerships, :source => :item, :source_type => 'User'

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  after_create do |household|
    household.memberships.create(:member => household.subscriber)
  end

end