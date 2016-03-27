class Group < ActiveRecord::Base
  include HumanizeName
  include HasModules
  include Abstractable

  belongs_to :user, :inverse_of => :subscriber_groups, counter_cache: true

  validates :name, :presence => true

  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :items, :through => :ownerships

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  after_create do |group|
    group.memberships.create(:member => group.user, :user => group.user)
  end

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  def has_member?(resource)
    memberships.find_by(:member => resource).present?
  end
end
