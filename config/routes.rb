Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations",
    omniauth_callbacks: "omniauth_callbacks"
  }
  get "rsvps/export", to: "rsvps#export", as: :export_rsvps

  resources :posts do
    collection { post :generate_description }
    resource :rsvp, only: %i[create destroy]
    resource :like, only: %i[create]
    resources :comments, only: %i[create destroy] do
      resource :like, only: %i[create]
    end
  end
  resources :notifications, only: [ :index ] do
    collection { patch :mark_all_read }
    collection { get  :unsubscribe }
    member      { patch :mark_read }
  end
  resources :users, only: %i[index show edit update destroy]
  resources :friendships
  resources :communities, only: %i[index show new create destroy] do
    member { get :members }
    resource :membership, only: %i[create destroy], controller: "community_memberships"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#index"

  get "about", to: "pages#about", as: :about
  get "legal", to: "pages#legal", as: :legal
end
