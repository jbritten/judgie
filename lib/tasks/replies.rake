namespace :replies do
  namespace :counts do
    desc "Check and correct yes/no/total reply counts"
    task :all => ["replies:counts:check", "replies:counts:correct"]

    desc "Check yes/no/total reply counts for accuracy"
    task :check => :environment do
      Question.find(:all).each do |question|
        puts "Question #{question.id} YES count is incorrect" if question.yes_count != question.yes_responses.count
        puts "Question #{question.id} NO count is incorrect" if question.no_count != question.no_responses.count
        puts "Question #{question.id} reply count is incorrect" if question.replies_count != question.replies.count
      end
    end

    desc "Correct yes/no/total reply counts" 
    task :correct => :environment do 
      Question.find(:all).each do |question|
        question.yes_count = question.yes_responses.count
        question.no_count = question.no_responses.count
        question.save
        Question.update_counters question.id, :replies_count => (question.replies.count - question.replies_count)
      end
    end
    
  end #namespace counts
end #namespace replies