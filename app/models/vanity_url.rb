class VanityUrl < ActiveRecord::Base
  validates_format_of     :slug, with: /\A[0-9a-z\-\_]+\z/i
  validates_uniqueness_of :slug, case_sensitive: false

  belongs_to :owner, :polymorphic => true

  def action
    [:render, :redirect].sample
  end
end
