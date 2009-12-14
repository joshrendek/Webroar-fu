set :user, "USERNAME"
set :domain, "IP_ADDR"
set :application, "application_name"
set :port, 12345
set :repository, "git@github.com:USERNAME/YOURAPP.git"
set :deploy_to, "/home/servlyapp"
set :keep_releases, 2

role :app, domain
role :web,domain
role :db,  domain, :primary => true

set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

 
set :mongrel_conf, "#{deploy_to}/config/mongrel_cluster.yml"

namespace :deploy do
  namespace :webroar do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the webroar appserver"
      task t, :roles => :app do
        #invoke_command checks the use_sudo variable to determine how to run the webroar command
        invoke_command "webroar #{t} #{application}", :via => run_method
      end
    end
  end

  desc "Custom restart task for webroar cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.webroar.restart
  end

  desc "Custom start task for webroar cluster"
  task :start, :roles => :app do
    deploy.webroar.start
  end

  desc "Custom stop task for webroar cluster"
  task :stop, :roles => :app do
    deploy.webroar.stop
  end

end

task :release_count do 
  run "ls -l #{deploy_to}/releases"
end

after "deploy:update", "deploy:cleanup"

after "deploy:update_code", :configure_database
desc "copy database.yml into the current release path"
task :configure_database, :roles => :app do
db_config = "#{deploy_to}/config/database.yml"
run "cp #{db_config} #{release_path}/config/database.yml"
end
