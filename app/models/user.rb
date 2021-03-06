class User < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  include HumanizeName
  include VanitizeUrl
  include Subscribable
  include Contactable

  include HasModules

  attr_accessor :login

  rolify
  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders], slug_column: :username
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :username, length: 2..15, format: { with: /\A(?:[a-z0-9][_]?)*[a-z0-9]\z/i, message: "invalid."} # "may only contain letters, numbers and underscores, must start and end with a letter or number, and cannot contain more than one underscore in a row."
  validates :username, format: { without: /\A\d+\Z/, message: "cannot contain only numbers." }
  validates :username, format: { without: /\A(?:admin|about|login|signin|signup|sign_out|register|terms-of-service|privacy-policy|feedback|users|businesses|households|groups|contacts|schedule|calendars|time|inventory|finances|projects)\Z/i, message: "restricted." }

  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_one :owner, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  def owners
    [owner]
  end

  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :groups, :through => :memberships, :source => :collective, :source_type => 'Group'
  has_many :businesses, :through => :memberships, :source => :collective, :source_type => 'Business'
  has_many :households, :through => :memberships, :source => :collective, :source_type => 'Household'
  has_many :attended_events, :through => :memberships, :source => :collective, :source_type => 'Calendar::Event'

  has_one :home_membership, -> { where collective_type: 'Household' }, :as => :member, :dependent => :destroy, :class_name => 'Membership'
  has_one :home, :through => :home_membership, :source => :collective, :source_type => 'Household'

  has_many :subsidiaries, :through => :ownerships, :source => :item, :source_type => 'Business'

  has_many :messages, :dependent => :destroy, :class_name => 'Messages::Message'

  has_many :intervals

  before_destroy do |user|
    Abstract.where(:user => user).update_all(user_id: nil)
  end

  def full_name
    if first_name
      first_name + " " + last_name
    else
      email
    end
  end
  def name
    full_name
  end

  def should_generate_new_friendly_id?
    username_changed?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end

  def is_owner?(resource)
    ownerships.find_by(:item => resource).present?
  end
  def is_member?(resource)
    memberships.find_by(:collective => resource).present?
  end

end
