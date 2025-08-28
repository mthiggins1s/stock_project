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
    # Private (username lookup, requires auth)
    get "/profiles/:username", to: "profiles#show", as: :profile

    # Public (public_id lookup, no auth)
    get "/profiles/public/:public_id", to: "profiles#show_public"
    get "/profiles/public/:public_id/portfolio", to: "profiles#portfolio"
  end
end
