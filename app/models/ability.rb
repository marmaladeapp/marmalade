class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :admin
      can :manage, :all
    else

      if user.subscribed?
        can :manage, Business, :subscriber => user
        can :manage, Household, :subscriber => user
        cannot :create, Business if user.plan.business_limit.present? && user.subscriber_businesses.size >= user.plan.business_limit
        cannot :create, Household if user.plan.household_limit.present? && user.subscriber_households.size >= user.plan.household_limit
      end

    end
  end
end
