Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA (zatím nevyužito)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#index"

  # Auth — sign in / log in card na landing page
  resource :session, only: [:new, :create, :destroy]

  # Profil (ikonka vlevo nahoře v topbaru)
  resource :profile, only: [:show, :edit, :update], controller: "profiles"

  resources :users, only: [:new, :create], path: "signup"

  get "password-reset", to: "password_resets#new", as: :new_password_reset
  post "password-reset", to: "password_resets#create", as: :password_reset
  get "password-reset/:token/edit", to: "password_resets#edit", as: :edit_password_reset
  patch "password-reset/:token", to: "password_resets#update", as: :update_password_reset

  get "email-confirmation/:token", to: "email_confirmations#show", as: :email_confirmation
  post "email-confirmation/resend", to: "email_confirmations#create", as: :resend_email_confirmation

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "watch-ad", to: "ads#watch", as: :watch_ad
  post "watch-ad", to: "ads#claim", as: :claim_ad
  get "banned", to: "sessions#banned", as: :banned

  # Volba jazyka — jednoduchý GET endpoint pro přepnutí locale
  get "locale/:locale", to: "locale#update", as: :set_locale

  resources :servers, only: [:index, :new, :create, :show, :edit, :update] do
    resource :contract_request, only: [:new, :create], controller: "contract_requests"
  end

  # --- API pro plugin komunikaci a server dashboard ---
  namespace :api do
    namespace :plugin do
      resources :servers, only: [:show] do
        get "config", on: :member, action: :plugin_config
      end
      get "players/:uuid/claims", to: "claims#index", as: :player_claims
      post "claims/:id/redeem", to: "claims#redeem", as: :redeem_claim
      post "claims/:id/fail", to: "claims#fail", as: :fail_claim
    end
  end

  # --- Admin sekce ---
  namespace :admin do
    root "dashboard#index"

    resources :servers, only: [:index, :show, :update]
    resources :contract_requests, only: [:index, :show, :update]
    resources :fraud_flags, only: [:index, :show, :update]
    resources :payouts, only: [:index, :show, :create] do
      member { patch :mark_paid }
    end

    resources :users, only: [:index, :show, :edit, :update] do
      member do
        patch :ban
        patch :unban
      end
    end
  end
end