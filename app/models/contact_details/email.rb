class ContactDetails::Email < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
end
