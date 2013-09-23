Antechamber::Application.routes.draw do

  get "/auth/:id/callback", to: 'callback#show'


end
