class Business < ActiveRecord::Base
  include HumanizeName

  belongs_to :subscriber, :class_name => "User"
  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :items, :through => :ownerships

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  after_create do |business|
    business.memberships.create(:member => business.subscriber)
  end

  accepts_nested_attributes_for :owners

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
