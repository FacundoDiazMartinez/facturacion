lock "~> 3.11.2"

set :application, "facturacion"
set :repo_url, "git@github.com:FacundoDiazMartinez/facturacion.git"
set :deploy_to, -> { "/home/facundo/#{fetch(:application)}_#{fetch(:stage)}" }

set :rbenv_ruby, '2.6.3'


set :linked_files, %w{config/master.key}

set :unicorn_workers, 2

set :keep_releases, 1

set :master_key_local_path, "config/master.key"