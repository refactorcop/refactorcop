require 'sidekiq/web'       #for background scheduler

Sidekiq::Web.use Rack::Auth::Basic, "Recovering Vegetarian Area" do |username, password|
  username == 'admin' && password == 'falafel'
end
