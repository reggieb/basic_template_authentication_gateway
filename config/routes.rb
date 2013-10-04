Antechamber::Application.routes.draw do

  devise_for :users

  get "auth/authorize", to: 'authorize#new', as: 'request_from_client_app'

  get "auth/:id/callback", to: 'callback#show', as: 'response_from_authority'

  post "oauth/token", to: 'authorize#create', as: 'callback_from_client_app'

  get "auth/user", to: 'people#show', as: 'user_lookup_by_client_app'

  root :to => "users#index"

  resources :users
  resources :client_apps

end
