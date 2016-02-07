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
    if !current_user.subscribed? && !request.fullpath.include?(user_subscription_path(current_user))
      redirect_to user_subscription_path(current_user)
    end
  end

end
