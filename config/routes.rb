Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :sign_up

  root "events#index"
  resources :events, only: %i[ index show ]
  resource :organization, only: %i[ new create show edit update ] do
    resources :events, only: %i[ index new create ], module: :organizations
  end

  namespace :settings do
    resource :email, only: [ :show, :update ]
    resource :password, only: [ :show, :update ]
    resource :profile, only: [ :show, :update ]
    resource :user, only: [ :show, :destroy ]

    root to: redirect("/settings/profile")
  end

  namespace :email do
    resources :confirmations, param: :token, only: [ :show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
