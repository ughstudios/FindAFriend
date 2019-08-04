# frozen_string_literal: true

Rails.application.routes.draw do
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
  resources :users

  resources :sessions, only: %i[new create destroy]

  get '/signup', to: 'users#new', as: 'signup'
  get '/login', to: 'sessions#new', as: 'login'
  get '/logout', to: 'sessions#destroy', as: 'logout'
  get '/findafriend', to: 'find_a_friend#search', as: 'findafriend'
  get '/dashboard', to: 'find_a_friend#dashboard', as: 'dashboard'

  root 'home#index'
end
