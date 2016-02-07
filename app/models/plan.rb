class Plan < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: [:slugged, :finders]
  has_many :users

  def blurb
    case billing_frequency
    when 1
      name + " (Monthly)"
    when 12
      name + " (Yearly)"
    else
      name
    end
  end
end
