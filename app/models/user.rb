require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :questions, :order => 'created_at DESC'
  has_many :replies
  has_many :replied_questions, :through => :replies, :source => :question
  has_one :stat, :dependent => :destroy

  def to_param
    "#{login}" if self.login
  end

  # Enumerations for Gender
  class Gender
    Guy = 0
    Girl = 1
    Count = 2

    VALUES = ['Guy', 'Girl'].freeze
  end
          
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40, :if => Proc.new {|login| login.nil?}
  validates_length_of       :email,    :within => 3..100, :if => Proc.new {|email| email.nil?}
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of :login, :with => /^\w+$/i, :message => "can only contain letters and numbers.", :if => Proc.new {|login| login.nil?}
  validates_email_veracity_of :email, :message => 'format is incorrect', :domain_check => false
  validates_acceptance_of   :terms_of_use_and_privacy_policy
  validates_presence_of :gender, :birthdate
  validates_inclusion_of :gender, :in => User::Gender::Guy..(User::Gender::Count-1)
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :terms_of_use_and_privacy_policy

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  GENDER = [
             ['Guy', 0],
             ['Girl', 1]
             ].freeze
               
  def age
    age = Date.today.year - read_attribute(:birthdate).year
    if Date.today.month < read_attribute(:birthdate).month || 
    (Date.today.month == read_attribute(:birthdate).month && read_attribute(:birthdate).day >= Date.today.day)
      age = age - 1
    end
    return age
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end
