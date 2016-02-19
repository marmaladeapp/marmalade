module HasModules
  extend ActiveSupport::Concern

  included do
    has_many :address_books, :as => :owner, :dependent => :destroy, :class_name => 'Contacts::AddressBook'
    has_many :calendars, :as => :owner, :dependent => :destroy, :class_name => 'Calendar::Calendar'
    has_many :projects, :as => :owner, :dependent => :destroy, :class_name => 'Projects::Project'
    has_many :time_sheets, :as => :owner, :dependent => :destroy, :class_name => 'TimeTracking::TimeSheet'
  end



  private



end
