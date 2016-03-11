class Project < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  has_many :messages, :dependent => :destroy, :class_name => 'Messages::Message'

  #after_create do |project|
  #  project.memberships.create(:member => project.user, :user => project.user)
  #end

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
end
