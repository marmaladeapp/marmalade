class Inventory::Container < ActiveRecord::Base
  include HumanizeName
  include Abstractable
  belongs_to :owner, polymorphic: true
  belongs_to :user

  has_many :ownerships, :as => :owner, :dependent => :destroy, :class_name => 'Ownership'
  has_many :inventory_items, :through => :ownerships, :source => :item, :source_type => 'Inventory::Item'

  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :scoped, :finders], :scope => :owner

  validates :name, :presence => true
  validates :slug, format: { without: /\A(?:containers)\Z/i, message: "restricted." }
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
