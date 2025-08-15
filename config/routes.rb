Rails.application.routes.draw do
  # Auth (canonical)
  post "/login", to: "sessions#create"

  # Users (API-only; no HTML new/edit)
  resources :users, except: %i[new edit]

  # Stocks (keep :show only if you really have it implemented)
  resources :stocks, only: %i[index show]

  # Profiles by username (one clear path; removes static /profiles/show)
  get "/profiles/:username", to: "profiles#show", as: :profile
end
