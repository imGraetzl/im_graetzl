CORS_DOMAIN_WHITELIST = [
  /imgraetzl\.at(:\d+)?/,
]

Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins CORS_DOMAIN_WHITELIST
    resource '*', headers: :any, methods: [:get, :post, :options], credentials: true, max_age: 600
  end
end
