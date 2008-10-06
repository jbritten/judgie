class BetaInvitation < ActiveRecord::Base
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_email_veracity_of :email, :message => 'format is incorrect', :domain_check => false

end
