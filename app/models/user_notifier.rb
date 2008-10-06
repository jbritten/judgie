class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Welcome to Judgie!'
  end

  def new_password(user, new_password)
    setup_email(user)
    @subject    += 'Your new Judgie password'
    @body[:new_password]  = new_password
  end
  
  protected
  
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "support@YOURSITENAME.com"
    @subject     = ""
    @sent_on     = Time.now
    @body[:user] = user
  end
end