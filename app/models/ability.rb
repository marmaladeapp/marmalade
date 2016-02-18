class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :admin
      can :manage, :all
    else

      if user.subscribed?
        can :manage, Collaborator, :user => user
        can :manage, Group, :user => user
        can :manage, Business, :user => user
        can :manage, Household, :user => user
        cannot :create, Collaborator if user.plan.collaborator_limit.present? && user.collaborators.size >= user.plan.collaborator_limit
        cannot :create, Group if user.plan.business_limit.present? && (user.subscriber_groups.size + user.subscriber_businesses.size) >= user.plan.business_limit
        cannot :create, Business if user.plan.business_limit.present? && (user.subscriber_groups.size + user.subscriber_businesses.size) >= user.plan.business_limit
        cannot :create, Household if user.plan.household_limit.present? && user.subscriber_households.size >= user.plan.household_limit
      end

    end
  end
end
