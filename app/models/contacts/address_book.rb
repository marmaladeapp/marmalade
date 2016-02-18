class Contacts::AddressBook < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user

  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :scoped, :finders], :scope => :owner

  def slug_candidates
    [
      :name
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end
end
