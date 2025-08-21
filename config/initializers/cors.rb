Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:4200"

    resource "*",
      headers: :any,
      expose: [ "Authorization" ], # ✅ allow Angular to read the token
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
