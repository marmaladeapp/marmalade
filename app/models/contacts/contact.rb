class Contacts::Contact < ActiveRecord::Base
  default_scope { order('lower(name)') }
  include Contactable
  belongs_to :context, polymorphic: true

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :address_books, :through => :owners, :source => :owner, :source_type => 'Contacts::AddressBook'

  belongs_to :item, polymorphic: true

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  def first_letter
    name[0].capitalize
  end
end
