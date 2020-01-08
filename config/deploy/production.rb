server "108.59.81.105", user: "facundo", roles: %w{app db web}
set :nginx_server_name, 'facturacion.litecodecloud.com'
set :delayed_job_workers, 1
set :delayed_job_pid_dir, '/tmp'
set :console_env, :production
set :console_user, :facundo # run rails console as appuser through sudo
set :console_role, :app