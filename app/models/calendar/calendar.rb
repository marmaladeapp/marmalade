class Calendar::Calendar < ActiveRecord::Base
  include HumanizeName
  belongs_to :owner, polymorphic: true
  belongs_to :project
  belongs_to :user

  has_many :ownerships, :as => :owner, :dependent => :destroy, :class_name => 'Ownership'
  has_many :events, :through => :ownerships, :source => :item, :source_type => 'Calendar::Event'

  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :scoped, :finders], :scope => :owner

  validates :slug, format: { without: /\A\d+\Z/, message: "cannot contain only numbers." }

  def slug_candidates
    [
      :name
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end
end
