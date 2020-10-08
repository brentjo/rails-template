require_relative 'boot'

require 'rails/all'

require_relative "../lib/middleware/fetch_metadata_processor"
require_relative "../lib/middleware/add_cross_origin_opener_policy"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Example
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Order will be SecureHeaders -> COOP -> FetchMetadata
    # The first two add important security headers we want to be present on all responses
    config.middleware.insert_before 0, Middleware::FetchMetadataProcessor
    config.middleware.insert_before 0, Middleware::AddCrossOriginOpenerPolicy
  end
end
