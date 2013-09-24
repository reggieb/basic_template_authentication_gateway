Antechamber::Application.routes.draw do

  devise_for :users

  get "/auth/:id/callback", to: 'callback#show'

  root :to => "users#index"

  resources :users
  resources :client_apps

end
