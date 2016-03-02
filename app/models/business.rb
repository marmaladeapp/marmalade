class Business < ActiveRecord::Base
  include HumanizeName

  include HasModules

  validates :slug, format: { without: /\A(?:admin|about|login|signin|signup|register|terms-of-service|privacy-policy|businesses|households|groups|contacts|calendars|time|finances|projects)\Z/i, message: "restricted." }

  belongs_to :user, :inverse_of => :subscriber_businesses, counter_cache: true
  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :items, :through => :ownerships

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  has_many :subsidiaries, :through => :ownerships, :source => :item, :source_type => 'Business'

  after_create do |business|
    business.memberships.create(:member => business.user, :user => business.user)
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

end
