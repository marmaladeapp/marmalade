module Contactable
  extend ActiveSupport::Concern

  included do
    has_many :emails, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Email'
    has_many :addresses, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Address'
    has_many :telephones, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Telephone'

    accepts_nested_attributes_for :emails
    accepts_nested_attributes_for :addresses
    accepts_nested_attributes_for :telephones

  end

end
