class App::AppController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout 'app/app'

  before_action :authenticate_user!
  before_filter :set_locale

  def set_locale
    I18n.locale = current_user.language
  end

  private

end
