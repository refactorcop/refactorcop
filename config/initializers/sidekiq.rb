# heroku redis url is set via : heroku config:set REDIS_PROVIDER=REDISGREEN_URL
#
require 'sidekiq/web'       #for background scheduler

Sidekiq::Web.use Rack::Auth::Basic, "Recovering Vegetarian Area" do |username, password|
  AdminAuthentication.call(username, password)
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDISGREEN_URL"], size: 4 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDISGREEN_URL"], size: 1 }
end
