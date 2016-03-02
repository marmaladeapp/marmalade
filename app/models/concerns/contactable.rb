module Contactable
  extend ActiveSupport::Concern

  included do
    has_many :emails, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Email'
    has_many :addresses, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Address'
    has_many :telephones, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Telephone'

    accepts_nested_attributes_for :emails, :reject_if => :all_blank
    accepts_nested_attributes_for :addresses, :reject_if => :all_blank
    accepts_nested_attributes_for :telephones, :reject_if => :all_blank

  end

end
