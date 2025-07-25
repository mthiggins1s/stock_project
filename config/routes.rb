Rails.application.routes.draw do
  get "sessions/create"
  scope "/" do
    post "login", to: "sessions#create"
  end
  resources :stocks, only: [ :index, :show ]

  # Users routes
  get "/users", to: "users#index"
  get "/users/:id", to: "users#show"
  post "/users", to: "users#create"
  put "/users/:id", to: "users#update"
  delete "/users/:id", to: "users#destroy"

  resources :users
end
