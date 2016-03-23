class Site::SiteController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource

  before_filter :set_locale

  def set_locale
    I18n.locale = extract_locale
  end

  private

  def extract_locale
    lang = request.env['HTTP_ACCEPT_LANGUAGE']
    if !lang.blank?
      case lang.scan(/^[a-z]{2}(?:-[a-zA-Z]{2})?/).first
      when 'en-GB'
        'en-GB'
      when 'en-US'
        'en-US'
      else
        case lang.scan(/^[a-z]{2}/).first
        when 'en'
          'en'
        else
          'en'
        end
      end
    else
      'en'
    end
  end

  def layout_by_resource
    if devise_controller?
      "auth/auth"
    else
      "site/site"
    end
  end

end

