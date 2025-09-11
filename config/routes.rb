Rails.application.routes.draw do
  scope defaults: { format: :json } do
    # --- Auth ---
    post "/login", to: "sessions#create"

    # --- Current User ---
    get "/me", to: "users#me"

    # --- Users ---
    resources :users, except: %i[new edit]

    # --- Stocks ---
    resources :stocks, only: %i[index show] do
      member do
        get :candles
      end
    end

    # --- Portfolio ---
    resources :portfolios, only: %i[index create destroy] do
      collection do
        get :candles, to: "stocks#portfolio_candles"
        get :summary, to: "stocks#portfolio_summary"
      end
    end

    # --- Profiles ---
    get "/profiles/:username", to: "profiles#show", as: :profile
    get "/profiles/public/:public_id", to: "profiles#show_public"
    get "/profiles/public/:public_id/portfolio", to: "profiles#portfolio"
  end
end
