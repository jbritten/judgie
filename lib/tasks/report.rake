namespace :report do
  namespace :count do
    desc "Report total number of users, questions, and replies"
    task :all => ["report:count:users", "report:count:questions", "report:count:replies"]
    
    desc "Count total users" 
    task :users => :environment do 
      count = CGI::Session::ActiveRecordStore::User.count 
      puts "Total users: #{count}" 
    end

    desc "Count total questions" 
    task :questions => :environment do 
      count = CGI::Session::ActiveRecordStore::Question.count 
      puts "Total quetions: #{count}" 
    end

    desc "Count total replies" 
    task :replies => :environment do 
      count = CGI::Session::ActiveRecordStore::Reply.count 
      puts "Total replies: #{count}" 
    end
    
  end #namespace count
end #namespace report