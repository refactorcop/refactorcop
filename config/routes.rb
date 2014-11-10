require 'sidekiq/web'       #for background scheduler

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get 'about/welcome'
  root :to => 'about#welcome'

  mount Sidekiq::Web => '/scheduler'

  get 'random' => "viewer#random"
  get 'project_not_found' => "viewer#project_not_found"
  get ':username/:name', controller: "viewer", action: "show_project", constraints: { name: /.*/ }
  get "*a", :to => "viewer#project_not_found"
end
