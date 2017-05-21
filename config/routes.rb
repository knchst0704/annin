Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :videos, only: [:show] do
    collection do
      get 'fetch'
    end
  end
end
