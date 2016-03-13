class Membership < ActiveRecord::Base
  include Abstractable
  default_scope { order(created_at: :asc) }

  belongs_to :user, :inverse_of => :subscriber_memberships

  belongs_to :collective, polymorphic: true
  belongs_to :member, polymorphic: true

  after_create :create_contact
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

  def create_contact
    if (["Calendar::Event"] & collective.class.name.lines.to_a).empty?
      unless Contacts::Contact.find_by(:item => member, :context => collective)
        contact = Contacts::Contact.create(:name => member.name, :item => member, :context => collective)
        contact.emails.create(:address => member.email)
        member.emails.each do |email|
          contact.emails.create(:address => email.address)
        end
        member.addresses.each do |address|
          contact.addresses.create(:line_1 => address.line_1,:line_2 => address.line_2,:city => address.city,:state => address.state,:zip => address.zip,:country => address.country)
        end
        member.telephones.each do |telephone|
          contact.telephones.create(:country_code => telephone.country_code,:number => telephone.number)
        end
      end
    end
  end

  def destroy_orphans
    if self.member.class.name == "User"
      unless Ownership.where(:owner => self.member, :user => self.user).any? || Membership.where(:member => self.member, :user => self.user).any?
        Collaborator.find_by(:user => self.user, :collaborator => self.member).destroy
      end
    end
  end
end
