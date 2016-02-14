class Membership < ActiveRecord::Base
  belongs_to :collective, polymorphic: true
  belongs_to :member, polymorphic: true
end
