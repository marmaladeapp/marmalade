class Project < ActiveRecord::Base
  include Abstractable
  belongs_to :owner, polymorphic: true
  belongs_to :user, :inverse_of => :subscriber_projects, counter_cache: true

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  has_many :messages, :dependent => :destroy, :class_name => 'Messages::Message'
  has_many :events, :dependent => :destroy, :class_name => 'Calendar::Event'
  has_many :timers, :dependent => :destroy, :class_name => 'TimeTracking::Timer'
  has_many :intervals, :dependent => :destroy, :class_name => 'TimeTracking::Interval'

  has_many :abstracts

  has_many :item_wallets, :as => :item, :dependent => :destroy
  has_many :wallets, :through => :item_wallets, :class_name => 'Finances::Wallet'

  has_many :ledgers, :class_name => 'Finances::Ledger'
  has_many :payments, :class_name => 'Finances::Payment'

  #after_create do |project|
  #  project.abstracts.create(:context => project.owner, :item => project, :user => project.user, :action => 'create') user here is subscriber - not correct.
  #end

  before_destroy do |project|
    project.abstracts.update_all(project_id: nil)
  end

  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :scoped, :finders], :scope => :owner

  validates :slug, format: { without: /\A(?:new)\Z/i, message: "restricted." }

  def slug_candidates
    [
      :name
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end
  def has_member?(resource)
    memberships.find_by(:member => resource).present?
  end
end
