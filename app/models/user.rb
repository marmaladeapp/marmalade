class User < ActiveRecord::Base
  include HumanizeName
  include VanitizeUrl

  attr_accessor :login
  default_scope -> { order('users.created_at DESC') }

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
  # validates :username, format: { without: /\A(?:admin|about|users|staff|login|signin|signup|register|edit|profile)\Z/i, message: "restricted." }

  belongs_to :plan
  has_many :payment_methods, :dependent => :destroy

  has_many :emails, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Email'
  has_many :addresses, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Address'
  has_many :telephones, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Telephone'

  has_many :subscriber_ownerships, :dependent => :destroy, :class_name => 'Ownership'
  has_many :subscriber_memberships, :dependent => :destroy, :class_name => 'Membership'

  has_many :subscriber_households, :dependent => :destroy, :class_name => 'Household'
  has_many :subscriber_businesses, :dependent => :destroy, :class_name => 'Business'

  has_many :ownerships, :as => :owner, :dependent => :destroy
  has_one :owner, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_one :home, :through => :owner, :source => :owner, :source_type => 'Household'

  def owners
    [owner]
  end

  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :businesses, :through => :memberships, :source => :collective, :source_type => 'Business'
  has_many :households, :through => :memberships, :source => :collective, :source_type => 'Household'

  has_many :collaborators, :dependent => :destroy
  has_many :collaborator_users, :through => :collaborators, :source => :collaborator

  has_many :collaborator_subscribers, :as => :collaborator, :class_name => 'Collaborator', :dependent => :destroy

  after_create do |user|
    user.collaborators.create(:collaborator => user)
  end

  before_destroy :unsubscribe

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

  def subscribed?
    first_name && last_name && plan && (plan.price.blank? || braintree_subscription_id) # last detail required = do they have braintree creds?
  end

  private

  def unsubscribe
    Braintree::Customer.delete(braintree_customer_id)
  end

end
