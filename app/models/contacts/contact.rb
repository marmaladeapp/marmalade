class Contacts::Contact < ActiveRecord::Base
  include Contactable
  belongs_to :context, polymorphic: true
  belongs_to :address_book
  belongs_to :item, polymorphic: true
end
