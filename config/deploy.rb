load 'config/deploy/shared' # set user and host here (gitignore'd)

set :application, "turbine"
default_run_options[:pty] = true
set :repository,  "git://github.com/myobie/turbine.git"
set :deploy_via, :remote_cache
set :repository_cache, "#{application}-src"
set :scm, "git"
set :branch, "master"
set :runner, user
set :runner_admin, runner

set :required_remote_gems, ['thor', 'rake', 'rack'] # thor is required to run the merb:gem:redeploy task

set :use_sudo, false

set :deploy_to, "/home/#{user}/apps/#{application}"

role :app, host
role :web, host
role :db,  host, :primary => true

after 'deploy:symlink' do
  run "ln -nfs #{shared_path}/log #{release_path}/log"
  run "ln -nfs #{shared_path}/gems/gems #{release_path}/gems/gems"
  run "ln -nfs #{shared_path}/gems/specifications #{release_path}/gems/specifications"
  # run "ln -nfs #{shared_path}/db #{release_path}/db" # sqlite3
  
  run "mkdir -p #{release_path}/tmp/cache"
  
  run "cd #{release_path} && thor merb:gem:redeploy"
end

namespace :deploy do

  desc "Restart Merb" 
  task :restart, :role => :app do  
    run "touch #{release_path}/tmp/restart.txt"
  end

  desc "Start Merb"
  task :start, :role => :app do
    # nothing to do here for now
  end

  desc "Stop Merb"
  task :stop, :role => :app do
    # nothing to do here for now
  end
  
  task :migrate, :role => :app do
    # nothing to do here for now
  end
  
  task :migrations, :role => :app do 
    # nothing to do here for now
  end
  
  namespace :remote_gems do
    task :install, :role => :app do
      sudo "gem install #{required_remote_gems.join(' ')} --no-ri --no-rdoc"
    end
  end

end

after "deploy:setup" do
  deploy.remote_gems.install  
  run "mkdir -p #{shared_path}/gems"
  run "mkdir -p #{shared_path}/gems/gems"
  run "mkdir -p #{shared_path}/gems/specifications"
end