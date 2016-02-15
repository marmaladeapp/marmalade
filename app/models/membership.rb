class Membership < ActiveRecord::Base
  default_scope { order('created_at ASC') }
  belongs_to :collective, polymorphic: true
  belongs_to :member, polymorphic: true

  def global_member
    self.member.to_global_id if self.member.present?
  end
  def global_member=(member)
    self.member = GlobalID::Locator.locate member
  end
end
