class Site::HomeController < Site::SiteController
  def index
    location = request.location # I believe this uses Google. Limits, maybe?
    @user_country = location.country_code
    if @user_country == 'RD'
      @user_country = 'GB'
      @user_currency = 'GBP'
      @user_time_zone = 'Europe/London'
    else
      @user_currency = ISO3166::Country.new(@user_country).currency_code
      @user_time_zone = Timezone::Zone.new(:latlon => [location.latitude, location.longitude]).zone
      # using geonames.org - LOOKINTO; there may be limits imposed.
    end
    @user_language = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}(?:-[a-zA-Z]{2})?/).first

    @features = [
      {
        :id => 'personal',
        :icon => 'fa-user',
        :hide_for_small => true,
        :name => 'Personal',
        :lead => 'Manage your own time and personal finances.',
        :description => ''
      },
      {
        :id => 'home',
        :icon => 'fa-home',
        :hide_for_small => true,
        :name => 'Home',
        :lead => 'See your time spent at home and household finances with a dashboard for your home.',
        :description => ''
      },
      {
        :id => 'business',
        :icon => 'fa-briefcase',
        :hide_for_small => true,
        :name => 'Business',
        :lead => 'Manage your businesses and see how they affect your net worth.',
        :description => ''
      },
      {
        :id => 'timeTracking',
        :icon => 'fa-clock-o',
        :hide_for_small => false,
        :name => 'Time Tracking',
        :lead => 'Track time spent on tasks and projects with your collaborators.',
        :description => ''
      },
      {
        :id => 'finances',
        :icon => 'fa-usd',
        :hide_for_small => false,
        :name => 'Finances',
        :lead => 'Gain an overview of your finances across your home and businesses.',
        :description => ''
      },
      {
        :id => 'projects',
        :icon => 'fa-folder-open',
        :hide_for_small => false,
        :name => 'Projects',
        :lead => 'Monitor projects and share crucial knowledge.',
        :description => ''
      },
      {
        :id => 'contacts',
        :icon => 'fa-book',
        :hide_for_small => false,
        :name => 'Contacts',
        :lead => 'Shared address books for your friends, colleagues and clients.',
        :description => ''
      },
      {
        :id => 'calendar',
        :icon => 'fa-calendar',
        :hide_for_small => false,
        :name => 'Calendar',
        :lead => 'Stay on top of what\'s happened and what\'s ahead at home and at work.',
        :description => ''
      },
      {
        :id => 'metrics',
        :icon => 'fa-line-chart',
        :hide_for_small => false,
        :name => 'Charts',
        :lead => 'Measure your time, income and spending with charts and visual data.',
        :description => ''
      }
    ]
    @plans = [
      {
        :name => 'Free',
        :features => [
          {:icon => 'fa-user',:description => 'Perfect for individuals'},
          {:icon => 'fa-user',:description => 'Manage your finances'},
          {:icon => 'fa-user',:description => 'Control your schedule'},
          {:icon => 'fa-user',:description => 'Handle your inventory'},
          {:icon => 'fa-folder-open',:description => 'Stay on top of 1 project'}
        ]
      },
      {
        :name => 'Light',
        :monthly => {
          :id => Plan.find_by(:slug => 'early_adopter_light_monthly_gbp').id,
          :gb_price => 500,
          :us_price => 900
        },
        :yearly => {
          :id => Plan.find_by(:slug => 'early_adopter_light_yearly_gbp').id,
          :gb_price => 4500,
          :us_price => 8100
        },
        :features => [
          {:icon => 'fa-group',:description => 'Up to 3 collaborators'},
          {:icon => 'fa-user',:description => '2 organizational units'},
          {:icon => 'fa-user',:description => 'Manage your home'},
          {:icon => 'fa-user',:description => 'Manage your business'},
          {:icon => 'fa-folder-open',:description => 'Manage up to 5 projects'}
        ]
      },
      {
        :name => 'Pro',
        :monthly => {
          :id => Plan.find_by(:slug => 'early_adopter_pro_monthly_gbp').id,
          :gb_price => 1500,
          :us_price => 2000
        },
        :yearly => {
          :id => Plan.find_by(:slug => 'early_adopter_pro_yearly_gbp').id,
          :gb_price => 13500,
          :us_price => 18000
        },
        :features => [
          {:icon => 'fa-group',:description => 'Up to 10 collaborators'},
          {:icon => 'fa-user',:description => '5 organizational units'},
          {:icon => 'fa-user',:description => 'Company subdivisions'},
          {:icon => 'fa-user',:description => '...'},
          {:icon => 'fa-folder-open',:description => 'Up to 15 projects'}
        ]
      },
      {
        :name => 'Plus',
        :monthly => {
          :id => Plan.find_by(:slug => 'early_adopter_plus_monthly_gbp').id,
          :gb_price => 2500,
          :us_price => 3500
        },
        :yearly => {
          :id => Plan.find_by(:slug => 'early_adopter_plus_yearly_gbp').id,
          :gb_price => 22500,
          :us_price => 31500
        },
        :features => [
          {:icon => 'fa-group',:description => 'Unlimited collaborators'},
          {:icon => 'fa-user',:description => 'Unlimited organizations'},
          {:icon => 'fa-user',:description => 'Unlimited subdivisions'},
          {:icon => 'fa-user',:description => '...'},
          {:icon => 'fa-folder-open',:description => 'Unlimited projects'}
        ]
      }
    ]
  end
  def terms_of_service
  end
  def privacy_policy
  end
  def feedback
    @email = Email.new()
  end
end
