class Contacts::Contact < ActiveRecord::Base
  include Contactable
  belongs_to :context, polymorphic: true

  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :address_books, :through => :memberships, :source => :collective, :source_type => 'Contacts::AddressBook'

  belongs_to :item, polymorphic: true

  accepts_nested_attributes_for :memberships
end
