web: bundle exec puma -C config/puma.rb
worker: rake jobs:work
release: bundle exec rails db:migrate && bundle exec rails db:seed
