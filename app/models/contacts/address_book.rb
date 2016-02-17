class Contacts::AddressBook < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user
end
