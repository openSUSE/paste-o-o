# frozen_string_literal: true

Rails.application.routes.draw do
  resources :pastes, only: %w[new create index show destroy], param: :permalink do
    get :raw
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/up' => 'rails/health#show'

  # Omniauth support
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :auths, only: %i[index new create destroy]

  # Defines the root path route ("/")
  root 'pastes#new'

  # Old API support
  post '/', to: 'oldapi#create'
  get '/:permalink', to: 'oldapi#redirect'
end
