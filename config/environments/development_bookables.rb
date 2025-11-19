# config/environments/development_bookables.rb
require_relative "development"

Rails.application.configure do
  # Gleiche Einstellungen wie development, nur explizit:
  config.eager_load = false

  # Hier direkt den gleichen Key wie in secrets.yml: development
  config.secret_key_base = "1e22a5b496c4c7a3020f2b6bb3ee7444deceba41defff5be9ed7cb99d5da4ebf0378bcd4643497fd8c373c8f3be657a1c"
end
