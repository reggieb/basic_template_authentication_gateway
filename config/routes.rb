Antechamber::Application.routes.draw do

  devise_for :users

  get "auth/authorize", to: 'authorize#request_from_client_app'

  get "auth/:id/callback", to: 'authorize#response_from_authority'

  post "oauth/token", to: 'authorize#callback_from_client_app'

  get "auth/user", to: 'authorize#identity_lookup_by_client_app'

  root :to => "users#index"

  resources :users
  resources :client_apps

end
