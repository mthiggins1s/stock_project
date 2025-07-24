Rails.application.routes.draw do
  resources :stocks, only: [ :index, :show ]
  # localhost:3000/users
  get "/users", to: "users#index"

  # localhost:3000/users/1
  get "/users/:id", to: "users#show"

  # localhost:3000/users
  post "/users", to: "users#create"

  # localhost:3000/users/1 (1 can be anything; example it can be 5 4 3 2 1)
  put "/users/:id", to: "users#update"

  # localhost:3000/users/1
  delete "/users/:id", to: "users#destroy"

  resources :users
end
