# heroku redis url is set via : heroku config:set REDIS_PROVIDER=REDISGREEN_URL
#
require 'sidekiq/web'       #for background scheduler

Sidekiq::Web.use Rack::Auth::Basic, "Recovering Vegetarian Area" do |username, password|
  username == 'admin' && password == 'falafel'
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDISGREEN_URL"], size: 3 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDISGREEN_URL"], size: 1 }
end
