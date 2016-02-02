class ContactDetails::Telephone < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
end
