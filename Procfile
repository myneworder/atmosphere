web: bundle exec puma -C ./config/puma.rb
worker: bundle exec sidekiq -q monitoring -q wrangler -q proxyconf -q billing -q flavors
clock: bundle exec clockwork app/clock.rb
