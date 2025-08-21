require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# ✅ Explicitly load dotenv before app initialization
require "dotenv"
Dotenv.load

module StockProject
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Autoload configuration
    config.autoload_lib(ignore: %w[assets tasks])
    config.autoload_paths << Rails.root.join("app", "blueprints")

    # Only loads a smaller set of middleware suitable for API-only apps.
    config.api_only = true

    # Example: set a default time zone if needed
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
