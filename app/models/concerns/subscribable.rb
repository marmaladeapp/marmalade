module Subscribable
  extend ActiveSupport::Concern

  included do
    belongs_to :plan
    has_many :payment_methods, :dependent => :destroy

    has_many :subscriber_ownerships, :dependent => :destroy, :class_name => 'Ownership'
    has_many :subscriber_memberships, :dependent => :destroy, :class_name => 'Membership'

    has_many :subscriber_households, :dependent => :destroy, :class_name => 'Household'
    has_many :subscriber_groups, :dependent => :destroy, :class_name => 'Group'
    has_many :subscriber_businesses, :dependent => :destroy, :class_name => 'Business'

    has_many :subscriber_wallets, :dependent => :destroy, :class_name => 'Finances::Wallet'
    has_many :subscriber_projects, :dependent => :destroy, :class_name => 'Project'

    has_many :collaborators, :dependent => :destroy
    has_many :collaborator_users, :through => :collaborators, :source => :collaborator
    has_many :collaborator_subscribers, :foreign_key => 'collaborator_id', :class_name => 'Collaborator', :dependent => :destroy

    after_create do |user|
      user.collaborators.create(:collaborator => user)
    end

    before_destroy :unsubscribe

  end

  def subscribed?
    first_name && last_name && plan && (plan.price.blank? || braintree_subscription_id) # last detail required = do they have braintree creds?
  end

  private

  def unsubscribe
    if braintree_customer_id
      Braintree::Customer.delete(braintree_customer_id)
    end
  end

end
