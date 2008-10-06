require 'railsmachine/recipes'

# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# From the command line, determine the type of deployment we should do
# The usage is cap deploy deployment=[deployment] branch=[branch]
# Where deployment == production or test
# Branch == the branch name in the repository to use
# The default is
# deployment == test
# branch == whatever branch you're working in

# Rails environment. Used by application setup tasks and migrate tasks.

set :rails_env, ENV['deployment'] || "test"
set :branch, ENV['branch'] || (`git branch | grep \* | sed "s/^\* //"`).strip!

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

# The name of your application. Used for directory and file names associated with
# the application.
set :application, "#{rails_env}" == "production" ? "judgie" : "judgie_test"

# Target directory for the application on the web and app servers.
set :deploy_to, "/var/www/apps/#{application}"

# Primary domain name of your application. Used as a default for all server roles.
set :domain, "#{rails_env}" == "production" ? "YOURSITENAME.com" : "test.YOURSITENAME.com"

# Login user for ssh.
set :user, "deploy"

# URL of your source repository.
set :scm, :git
set :repository, "YOUR-DEPOT-LOCATION"
set :deploy_via, :remote_cache

# Automatically symlink these directories from curent/public to shared/public.
# set :app_symlinks, %w{photo document asset}

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

# Modify these values to execute tasks on a different server.
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

# =============================================================================
# APACHE OPTIONS
# =============================================================================
set :apache_default_vhost, false
set :apache_proxy_port, "#{rails_env}" == "production" ? 8000 : 8010
set :apache_proxy_servers, "#{rails_env}" == "production" ? 1 : 1
set :apache_proxy_address, "127.0.0.1"
set :apache_ssl_enabled, false

# =============================================================================
# MONGREL OPTIONS
# =============================================================================
set :mongrel_servers, apache_proxy_servers
set :mongrel_port, apache_proxy_port
set :mongrel_address, apache_proxy_address
set :mongrel_environment, "#{rails_env}"
set :mongrel_pid_file, "/var/run/mongrel_cluster/#{application}.pid"
set :mongrel_conf, "/etc/mongrel_cluster/#{application}.conf"
# set :mongrel_user, user
# set :mongrel_group, group

# =============================================================================
# SCM OPTIONS
# =============================================================================
#set :scm,"subversion"

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# CAPISTRANO OPTIONS
# =============================================================================
# default_run_options[:pty] = true
set :keep_releases, 20


# =============================================================================
# CUSTOM CAPISTRANO RECIPES
# =============================================================================

# Disable monit during any mongrel or apache restart
if rails_env == "production"
  before  'mongrel:cluster:restart', 'monit:mongrel:unmonitor'
  before  'mongrel:cluster:stop', 'monit:mongrel:unmonitor'
  after  'mongrel:cluster:restart', 'monit:mongrel:monitor'
  after  'mongrel:cluster:start', 'monit:mongrel:monitor'
  before  'apache:restart', 'monit:mongrel:unmonitor'
  before  'apache:stop', 'monit:mongrel:unmonitor'
  after  'apache:restart', 'monit:mongrel:monitor'
  after  'apache:start', 'monit:mongrel:monitor'
end

# The sphinx search configuration files for the test and production environments need 
# to be generated with local access to the respective database.  Therefore, we need to 
# generate these files every time our source code is updated during deployment.
desc "Generate the sphinx configuration file after every deployment"
task :after_update_code, :roles => :app do
  run("cd #{release_path}; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:configure")
end

namespace :sphinx do

  desc <<-DESC
  Start the Sphinx search daemon
  DESC
  task :start do
    if rails_env == "production"
      cmd = "monit start sphinx_judgie"
      send(run_method, cmd)
    else
      run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:daemon:start")
    end
  end

  desc <<-DESC
  Stop the Sphinx search daemon
  DESC
  task :stop do
    if rails_env == "production"
      cmd = "monit stop sphinx_judgie"
      send(run_method, cmd)
    else
      run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:daemon:stop")
    end
  end

  desc <<-DESC
  Restart the Sphinx search daemon
  DESC
  task :restart do
    if rails_env == "production"
      cmd = "monit restart sphinx_judgie"
      send(run_method, cmd)
    else
      run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:daemon:restart")
    end
  end

  desc <<-DESC
  Show the status of the Sphinx search daemon
  DESC
  task :status do
    run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:daemon:status")
  end

  namespace :index do
    desc <<-DESC
    Reindex and rotate the main index.
    DESC
    task :main do
      run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:index:main")
    end

    desc <<-DESC
    Reindex and rotate the delta index.
    DESC
    task :delta do
      run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:index:delta")
    end

    desc <<-DESC
    Merge the delta index into the main index.
    DESC
    task :merge do
      run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=#{rails_env} ultrasphinx:index:merge")
    end
  end
end # sphinx

namespace :monit do

  desc <<-DESC
  Start Monit
  DESC
  task :start do
    cmd = "monit -c /etc/monitrc"
    send(run_method, cmd)
  end

  desc <<-DESC
  Quit Monit
  DESC
  task :quit do
    cmd = "monit quit"
    send(run_method, cmd)
  end

  desc <<-DESC
  Show the status of Monit monitored processes
  DESC
  task :status do
    cmd = "monit status"
    send(run_method, cmd)
  end

  desc <<-DESC
  Show the summary of Monit monitored processes
  DESC
  task :summary do
    cmd = "monit summary"
    send(run_method, cmd)
  end
  
  namespace :mongrel do
    desc <<-DESC
    Enable monitoring of the mongrel group
    DESC
    task :monitor do
      cmd = "monit -g mongrel_judgie monitor all"
      send(run_method, cmd)
    end

    desc <<-DESC
    Disable monitoring of the mongrel group
    DESC
    task :unmonitor do
      cmd = "monit -g mongrel_judgie unmonitor all"
      send(run_method, cmd)
    end
  end # monit:mongrel
  
end #monit

desc <<-DESC
Run a user, question, reply report on the production environment.
DESC
task :report do
  run("cd #{deploy_to}/current; /usr/bin/rake RAILS_ENV=production report:count:all")
end

