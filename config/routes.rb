require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get 'about/welcome'
  root :to => 'about#welcome'

  # Github authentication
  get '/auth/:provider/callback', to: 'sessions#create'

  mount Sidekiq::Web => '/scheduler'

  resources :projects, only: [:index] do
    get :import, on: :collection
    get :search, on: :collection
    get :send_cops, on: :member
  end

  get 'random' => 'projects#random'
  get 'project_not_found' => 'projects#not_found'
  get ':username/:name' => 'projects#show', constraints: { name: /.*/ }, as: :find_project
  get '*a/*b', to: 'projects#not_found'
end
