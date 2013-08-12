require 'api/api'

Air::Application.routes.draw do
  namespace :admin do
    resources :appliance_sets, only: [:index, :show, :edit, :update, :destroy]
  end

  devise_for :users
  root to: 'home#index'

  mount API::API => '/api'
end
