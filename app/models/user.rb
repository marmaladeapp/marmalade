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

  has_many :emails, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Email'
  has_many :addresses, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Address'
  has_many :telephones, :as => :owner, :dependent => :destroy, :class_name => 'ContactDetails::Telephone'

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

  private

end
