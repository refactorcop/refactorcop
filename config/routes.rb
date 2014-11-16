require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get 'about/welcome'
  root :to => 'about#welcome'

  mount Sidekiq::Web => '/scheduler'

  resources :projects, only: [] do
    member do
      get :send_cops
    end
  end

  get 'random' => 'projects#random'
  get 'project_not_found' => 'projects#not_found'
  get ':username/:name' => 'projects#show', constraints: { name: /.*/ }
  get '*a/*b', to: 'projects#not_found'
end
