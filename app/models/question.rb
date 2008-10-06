class Question < ActiveRecord::Base
  belongs_to :user
  has_many :guy_responses, :through => :replies, :source => :user, :conditions => ['gender = ?', User::Gender::Guy]
  has_many :girl_responses, :through => :replies, :source => :user, :conditions => ['gender = ?', User::Gender::Girl]
  has_many :yes_responses, :class_name => "Reply", :conditions => ['yes = TRUE']
  has_many :no_responses, :class_name => "Reply", :conditions => ['yes = FALSE']
  has_many :age_0_19_responses, :class_name => "Reply", :finder_sql => 'SELECT * FROM `replies` INNER JOIN users ON replies.user_id = users.id WHERE ((replies.question_id = #{id}) AND (DATEDIFF(replies.created_at, users.birthdate) < #{365 * 20}))'
  has_many :age_20_29_responses, :class_name => "Reply", :finder_sql => 'SELECT * FROM `replies` INNER JOIN users ON replies.user_id = users.id WHERE ((replies.question_id = #{id}) AND (DATEDIFF(replies.created_at, users.birthdate) < #{365 * 30}) AND (DATEDIFF(replies.created_at, users.birthdate) >= #{365 * 20}))'
  has_many :age_30_39_responses, :class_name => "Reply", :finder_sql => 'SELECT * FROM `replies` INNER JOIN users ON replies.user_id = users.id WHERE ((replies.question_id = #{id}) AND (DATEDIFF(replies.created_at, users.birthdate) < #{365 * 40}) AND (DATEDIFF(replies.created_at, users.birthdate) >= #{365 * 30}))'
  has_many :age_40_49_responses, :class_name => "Reply", :finder_sql => 'SELECT * FROM `replies` INNER JOIN users ON replies.user_id = users.id WHERE ((replies.question_id = #{id}) AND (DATEDIFF(replies.created_at, users.birthdate) < #{365 * 50}) AND (DATEDIFF(replies.created_at, users.birthdate) >= #{365 * 40}))'
  has_many :replies, :dependent => :destroy
  
  is_indexed :fields => ['created_at', 'the_question'], :delta => true

  validates_presence_of :the_question
  validates_length_of :the_question, :within => 5..120
  
  attr_protected :yes_count, :no_count, :replies_count
  
  # Record the question in the user's stats
  def after_create
    self.user.stat.increment!(:question_count)
  end

  # Return the percentage of responses that are yes.  Output is a whole integer.
  def percentage_yes
    return 0 if yes_count == 0
    
    ((yes_count.to_f / replies_count) * 100).to_i
  end

  # Return the percentage of responses that are no.  Output is a whole integer.
  def percentage_no
    return 0 if no_count == 0

    100 - percentage_yes
  end
  
  # Return a chart showing the yes/no breakdown of responses
  def chart_responses
    chart = GoogleChart.pie_400x150(["#{percentage_yes}% yes", percentage_yes], ["#{percentage_no}% no", percentage_no])
    chart.colors = ['BCDEA5', 'E6F9BC']
    return chart
  end
  
  # Return a chart showing the gender breakdown of responses
  def chart_gender
    women_count = girl_responses.count
    women_percentage = (women_count == 0) ? 0 : ((women_count.to_f / replies.count) * 100).to_i
    men_count = guy_responses.count
    men_percentage = (men_count == 0) ? 0 : (100 - women_percentage)
    chart = GoogleChart.pie_400x150(["#{women_percentage}% girls", women_percentage], ["#{men_percentage}% guys", men_percentage])
    chart.colors = ['DEA4A4', 'A4C0DE']
    return chart
  end
  
  # Return a chart showing the response breakdown by gender and yes/no
  def chart_gender_2
    total_count = replies.count
    women_yes_count = girl_responses.count(:conditions => ['yes = TRUE'])
    women_yes_percent = (women_yes_count == 0) ? 0 : ((women_yes_count.to_f / total_count) * 100).to_i
    women_no_count = girl_responses.count - women_yes_count
    women_no_percent = (women_no_count == 0) ? 0 : ((women_no_count.to_f / total_count) * 100).to_i
    men_yes_count = guy_responses.count(:conditions => ['yes = TRUE'])
    men_yes_percent = (men_yes_count == 0) ? 0 : ((men_yes_count.to_f / total_count) * 100).to_i
    men_no_count = guy_responses.count - men_yes_count
    # Calculate men_no_percent differently to be sure all values add up to 100%
    men_no_percent = (men_no_count == 0) ? 0 : 100 - women_yes_percent - women_no_percent - men_yes_percent
    
    chart = GoogleChart.pie_400x150(["#{women_yes_percent}% girls who said yes", women_yes_percent], ["#{women_no_percent}% girls who said no", women_no_percent], ["#{men_no_percent}% guys who said no", men_no_percent],["#{men_yes_percent}% guys who said yes", men_yes_percent])
    chart.colors = ['DEA4A4', 'FDD3D7', 'CADCF8', 'A4C0DE']
    return chart
  end
  
  # Return a chart showing the yes/no breakdown of female responses
  def chart_women
    women_count = girl_responses.count
    yes_count = girl_responses.count(:conditions => ['yes = TRUE'])
    yes_percentage = (yes_count == 0) ? 0 : ((yes_count.to_f / women_count) * 100).to_i
    no_count = women_count - yes_count
    no_percentage = (no_count == 0) ? 0 : (100 - yes_percentage)
    
    chart = GoogleChart.pie_200x75(["#{yes_percentage}% yes", yes_percentage], ["#{no_percentage}% no", no_percentage])
    chart.colors = ['DEA4A4', 'FDD3D7']
    return chart
  end
  
  def chart_men
    men_count = guy_responses.count
    yes_count = guy_responses.count(:conditions => ['yes = TRUE'])
    yes_percentage = (yes_count == 0) ? 0 : ((yes_count.to_f / men_count) * 100).to_i
    no_count = men_count - yes_count
    no_percentage = (no_count == 0) ? 0 : (100 - yes_percentage)
    
    chart = GoogleChart.pie_200x75(["#{yes_percentage}% yes", yes_percentage], ["#{no_percentage}% no", no_percentage])
    chart.colors = ['A4C0DE', 'CADCF8']
    return chart
  end
  
  # 
  # Has the given user already replied to the question?
  #
  # Input: A user object
  # Output: Boolean (true when user has already replied to the question)
  def answered_by?(user)
    replies.exists?(:user_id => user)
  end
  
end
