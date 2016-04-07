class Business < ActiveRecord::Base
  include HumanizeName

  include HasModules
  include Abstractable

  validates :name, :presence => true
  validates :slug, format: { without: /\A(?:admin|about|login|signin|signup|sign_out|register|terms-of-service|privacy-policy|feedback|users|businesses|households|groups|contacts|schedule|calendars|time|inventory|finances|projects)\Z/i, message: "restricted." }

  belongs_to :user, :inverse_of => :subscriber_businesses, counter_cache: true
  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :items, :through => :ownerships

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  has_many :subsidiaries, :through => :ownerships, :source => :item, :source_type => 'Business'

  after_create do |business|
    business.memberships.create(:member => business.user, :user => business.user, :confirmed => true)
  end

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  include VanitizeUrl
  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :slug,
      [:name]
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def is_owner?(resource)
    ownerships.find_by(:item => resource).present?
  end

  def has_member?(resource)
    memberships.find_by(:member => resource).present?
  end
end
