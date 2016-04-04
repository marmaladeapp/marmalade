class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :admin
      can :manage, :all
    else
      can :manage, User, :id => user.id

      if user.subscribed?
        can :read, User
        can :manage, Collaborator, :user => user
        can :manage, Group, :user => user
        can :manage, Business, :user => user
        can :manage, Household, :user => user
        cannot :create, Collaborator if user.plan.collaborator_limit.present? && user.collaborators.size >= user.plan.collaborator_limit
        cannot :create, Group if user.plan.business_limit.present? && (user.subscriber_groups.size + user.subscriber_businesses.size) >= user.plan.business_limit
        cannot :create, Business if user.plan.business_limit.present? && (user.subscriber_groups.size + user.subscriber_businesses.size) >= user.plan.business_limit
        cannot :create, Household if user.plan.household_limit.present? && user.subscriber_households.size >= user.plan.household_limit

        can :read, Group do |group|
          group.has_member?(user)
        end
        can :read, Business do |business|
          business.has_member?(user)
        end
        can :read, Household do |household|
          household.has_member?(user)
        end

        can :manage, Membership do |membership|
          membership.collective.user == user || membership.member == user
        end
        can :manage, Ownership do |ownership|
          ownership.owner == user || (ownership.owner && ownership.owner.user == user) || ownership.owner == nil
        end

        can :manage, Finances::Ledger do |ledger|
          ledger.context == user || ledger.context.has_member?(user)
        end
        can :manage, Finances::Wallet do |wallet|
          wallet.context == user || wallet.context.has_member?(user)
        end

        can :manage, Finances::Wallet, :user => user
        can :manage, Project, :user => user
        cannot :create, Finances::Wallet if user.plan.wallet_limit.present? && user.subscriber_wallets.size >= user.plan.wallet_limit
        cannot :create, Project if user.plan.project_limit.present? && user.subscriber_projects.size >= user.plan.project_limit

        can :read, Project do |project|
          project.owner == user || project.owner.has_member?(user)
        end
        can :update, Project do |project|
          project.owner == user || project.owner.has_member?(user)
        end

        can :manage, Contacts::Contact, :context => user.business_ids # or something like that, right? Should be easy.
        can :manage, Contacts::Contact, :context => user.household_ids # and then we can add another set just like that, no?
      end

    end
  end
end
