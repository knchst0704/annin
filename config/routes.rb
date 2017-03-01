Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root 'home#index'

  resources :videos, only: [:show] do
    collection do
      get 'search'
      get 'fetch'
    end
  end

  namespace :api, { format: 'json' } do
    resources :videos, only: [:index, :show] do
      collection do
        get 'tag'
      end
    end
  end
end
