# Mute sidekiq logs in tests
Sidekiq.configure_client do |config|
  config.logger = Rails.env.test? ? Logger.new(nil) : Sidekiq.logger
end