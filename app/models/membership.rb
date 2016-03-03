class Membership < ActiveRecord::Base
  default_scope { order(created_at: :asc) }

  belongs_to :user, :inverse_of => :subscriber_memberships

  belongs_to :collective, polymorphic: true
  belongs_to :member, polymorphic: true

  # after_create :create_contact
  after_destroy :destroy_orphans

  def global_member
    self.member.to_global_id if self.member.present?
  end
  def global_member=(member)
    self.member = GlobalID::Locator.locate member
  end

  def global_collective
    self.collective.to_global_id if self.collective.present?
  end
  def global_collective=(collective)
    self.collective = GlobalID::Locator.locate collective
  end

  private

  def destroy_orphans
    if self.member.class.name == "User"
      unless Ownership.where(:owner => self.member, :user => self.user).any? || Membership.where(:member => self.member, :user => self.user).any?
        Collaborator.find_by(:user => self.user, :collaborator => self.member).destroy
      end
    end
  end
end
