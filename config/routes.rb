Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root 'home#index'

  resources :videos, only: [:show] do
    collection do
      get 'fetch'
      get 'search'
    end
  end
end
