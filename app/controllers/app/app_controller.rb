class App::AppController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout 'app/app'

  before_action :authenticate_user!
  before_action :subscribe_user!
  before_filter :set_locale

  def set_locale
    I18n.locale = current_user.language
  end

  private

  def subscribe_user!
    unless request.fullpath.include?(user_subscribe_path(current_user)) || request.fullpath.include?(user_payment_path(current_user))
      if !current_user.subscribed? && !(request.fullpath.include?(user_subscription_path(current_user)) || request.fullpath.include?(user_payment_path(current_user)))
        if !(current_user.first_name && current_user.last_name && current_user.plan)
          redirect_to user_subscription_path(current_user)
        else
          redirect_to user_payment_path(current_user)
        end
      end
    end
  end

end
