module HasContacts
  extend ActiveSupport::Concern

  included do
    has_many :address_books, :as => :owner, :dependent => :destroy, :class_name => 'Contacts::AddressBook'
  end



  private



end
