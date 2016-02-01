class Site::HomeController < Site::SiteController
  def index
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
          :price => 500
        },
        :yearly => {
          :price => 4500
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
          :price => 1500
        },
        :yearly => {
          :price => 13500
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
          :price => 2500
        },
        :yearly => {
          :price => 22500
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
end
