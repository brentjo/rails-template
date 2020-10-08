Rails.application.routes.draw do
  # Landing page
  root 'dashboard#show'

  # Registration routes
  get '/register', to: 'users#new', as: 'register'
  post '/users', to: 'users#create'

  # Login routes
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  post '/logout', to: 'sessions#destroy'
end
