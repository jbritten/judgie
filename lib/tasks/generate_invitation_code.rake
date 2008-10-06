# Usage: rake generate_invite email=invitee@host.com

desc "Generate an invitation code.\n\nUsage is rake generate_invitation_code email=<email>"
task :generate_invitation_code do
  require 'rubygems'
  require 'digest/md5'

  email = ENV['email']
  key = Digest::MD5.hexdigest("23dsff643498KJSDFG86jkghkpo230sx"+email)
  puts "#{email}: #{key}"
end