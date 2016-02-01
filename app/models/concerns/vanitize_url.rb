module VanitizeUrl
  extend ActiveSupport::Concern

  included do
    validate :check_vanity
    after_save :vanitize_url
    delegate :url_helpers, to: "Rails.application.routes"
    has_one :vanity_url, :as => :owner, :dependent => :destroy
  end

  def path
    if self.class.name == "User"
      url_helpers.send :"#{self.class.name.underscore}_path", self.username
    else
      url_helpers.send :"#{self.class.name.underscore}_path", self.slug
    end
  end

  def vanitize_url
    if self.vanity_url
      case self.class.name
      when 'User'
        self.vanity_url.update_attributes(:slug => self.username, :target => self.path)
      else
        self.vanity_url.update_attributes(:slug => self.slug, :target => self.path)
      end
    else
      case self.class.name
      when 'User'
        self.create_vanity_url(:slug => self.username, :target => self.path)
      else
        self.create_vanity_url(:slug => self.slug, :target => self.path)
      end
    end
  end

  def check_vanity
    if self.class.name == 'User'
      unless self.username.blank?
        if VanityUrl.find_by_slug(self.username)
          unless VanityUrl.find_by_slug(self.username) == self.vanity_url
            unless self.errors.full_messages.include?("Username has already been taken")
              errors.add(:base, 'Username has already been taken')
            end
            false
          end
        end
      end # Holding onto the below for reference - we'll surely handle pages and posts here.
    #elsif self.class.base_class.name == 'Organization'
    #  unless self.name.blank?
    #    if VanityUrl.find_by_slug(self.name.parameterize)
    #      unless VanityUrl.find_by_slug(self.name.parameterize) == self.vanity_url
    #        errors.add(self.class.model_name.singular, 'name has already been taken')
    #        false
    #      end
    #    end
    #  end
    #else
    #  unless self.slug.blank?
    #    if VanityUrl.find_by_slug(self.slug)
    #      unless VanityUrl.find_by_slug(self.slug) == self.vanity_url
    #        errors.add(self.class.model_name.singular, 'name has already been taken')
    #        false
    #      end
    #    end
    #  end
    end
  end
end
