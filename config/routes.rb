Rails.application.routes.draw do
  scope defaults: { format: :json } do
    # --- Auth ---
    post "/login", to: "sessions#create"

    # --- Users ---
    resources :users, except: %i[new edit]

    # --- Stocks (public) ---
    resources :stocks, only: %i[index show]

    # --- Portfolio (JWT protected) ---
    resources :portfolios, only: %i[index create destroy]

    # --- Profiles ---
    get "/profiles/:username", to: "profiles#show", as: :profile
  end
end
