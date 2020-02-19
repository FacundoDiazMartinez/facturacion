server "108.59.81.105", user: "facundo", roles: %w{app db web}
set :nginx_server_name, 'facturacion.litecodecloud.com'
set :delayed_job_workers, 1
set :delayed_job_pid_dir, '/tmp'
set :console_env, :production
set :console_user, :facundo # run rails console as appuser through sudo
set :console_role, :app

set :logger_default_file, "#{deploy_to}/shared/log/unicorn.stdout.log" # default <release_path>/log/<rails_env>.log
set :logger_lines, 500 # default 100