Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # Auth — sign in / log in card na landing page
  resource :session, only: [:new, :create, :destroy]

  # Profil (ikonka vlevo nahoře v topbaru)
  resource :profile, only: [:show, :edit, :update], controller: "profiles"

  resources :users, only: [:new, :create], path: "signup"

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "watch-ad", to: "ads#watch", as: :watch_ad

  # volba jazyka — jednoduchý GET endpoint pro přepnutí locale
  get "locale/:locale", to: "locale#update", as: :set_locale

  resources :servers, only: [:index, :new, :create, :show, :edit, :update] do
    resource :contract_request, only: [:new, :create], controller: "contract_requests"
  end

  # --- do budoucna, pro plugin komunikaci a server dashboard ---
  namespace :api do
    namespace :plugin do
      resources :servers, only: [:show] do
        get "config", on: :member
      end
      get "players/:uuid/claims", to: "claims#index", as: :player_claims
      post "claims/:id/redeem", to: "claims#redeem", as: :redeem_claim
      post "claims/:id/fail", to: "claims#fail", as: :fail_claim
    end
  end

  namespace :admin do
    root "dashboard#index"
    resources :servers, only: [:index, :show, :update]
    resources :contract_requests, only: [:index, :show, :update]
    resources :fraud_flags, only: [:index, :show, :update]
    resources :payouts, only: [:index, :show]
  end
end