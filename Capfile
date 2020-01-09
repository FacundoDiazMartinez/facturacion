require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
require 'capistrano/linked_files'
require 'capistrano/rbenv'
require 'capistrano/rbenv_install'
require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/unicorn_nginx'
require 'capistrano/postgresql'
require 'capistrano/safe_deploy_to'
require 'capistrano/delayed_job'
require 'capistrano/rails/console'
require 'capistrano/logger'

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
