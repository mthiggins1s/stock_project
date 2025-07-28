Rails.application.routes.draw do
  get "profiles/show"
  get "sessions/create"
  scope "/" do
    post "login", to: "sessions#create"
  end
  resources :stocks, only: [ :index, :show ]
  scope :profiles do
    get ":username", to: "profiles#show"
  end

  # Users routes
  get "/users", to: "users#index"
  get "/users/:id", to: "users#show"
  post "/users", to: "users#create"
  put "/users/:id", to: "users#update"
  delete "/users/:id", to: "users#destroy"

  resources :users
end
