# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

def signin  
    @current_user = mock_model(User)     
    User.should_receive(:find_by_id).any_number_of_times.and_return(@current_user)
    User.should_receive(:find).any_number_of_times.and_return(@current_user)
    request.session[:user] = @current_user
end

module SigninRequiredHelper
  # This module came from http://blog.wolfman.com/articles/2007/07/28/rspec-testing-all-actions-of-a-controller
  
  # get all actions for specified controller
  def get_all_actions(cont)
    c= Module.const_get(cont.to_s.pluralize.capitalize + "Controller")
    c.public_instance_methods(false).reject{ |action| ['rescue_action'].include?(action) }
  end

  # test actions fail if not logged in
  # opts[:exclude] contains an array of actions to skip
  # opts[:include] contains an array of actions to add to the test in addition
  # to any found by get_all_actions
  def controller_actions_should_fail_if_not_logged_in(cont, opts={})
    except= opts[:except] || []
    actions_to_test= get_all_actions(cont).reject{ |a| except.include?(a) }
    actions_to_test += opts[:include] if opts[:include]
    actions_to_test.each do |a|
      get a
      response.should_not be_success
      response.should redirect_to('http://test.host/')
    end
  end
end
