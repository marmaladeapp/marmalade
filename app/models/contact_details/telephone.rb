class ContactDetails::Telephone < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  phony_normalize :number, default_country_code: 'US'
end
