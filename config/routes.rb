Rails.application.routes.draw do
  resources :stocks, only: [ :index, :show ]
  # localhost:3000/users
  get "/users", to: "users#index"
end
