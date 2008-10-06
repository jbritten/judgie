class Reply < ActiveRecord::Base
  belongs_to :question, :counter_cache => true
  belongs_to :user
  
  # Ensure a user cannot reply to the same question multiple times
  validates_uniqueness_of :user_id, :scope => [:question_id]
  
  class Response
    No = 0
    Yes = 1
  end
  
  # When a new reply is created, record it in the user's stats and update the response cache
  def after_create
    Stat.increment_counter(:reply_count, self.user.stat.id)
    
    if self.yes?
      Question.increment_counter(:yes_count, question.id)
    else
      Question.increment_counter(:no_count, question.id)
    end
  end

  # When a reply is destroyed, update the user's stats
  def before_destroy
    if self.yes?
      Question.decrement_counter(:yes_count, question.id)
    else
      Question.decrement_counter(:no_count,  question.id)
    end
    
    Stat.decrement_counter(:reply_count, self.user.stat.id)
  end
  
end
