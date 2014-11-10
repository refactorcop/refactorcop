require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get 'about/welcome'
  root :to => 'about#welcome'

  mount Sidekiq::Web => '/scheduler'

  get 'random' => 'projects#random'
  get 'project_not_found' => 'projects#not_found'
  get ':username/:name' => 'projects#show', constraints: { name: /.*/ }
  get '*a', :to => 'projects#not_found'
end
