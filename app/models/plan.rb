class Plan < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: [:slugged, :finders]
  has_many :users

  def blurb
    case billing_frequency
    when 1
      name + " - £" + price.to_i.to_s + " per month"
    when 12
      name + " - £" + price.to_i.to_s + " per year"
    else
      name
    end
  end
end
