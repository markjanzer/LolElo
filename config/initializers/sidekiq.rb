redis_url = ENV['REDISCLOUD_URL'] || 'redis://localhost:6379/0'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

schedule_file = "config/schedule.yml"
if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

Sidekiq.configure_client do |config|
  # Mute sidekiq logs in tests
  config.logger = Rails.env.test? ? Logger.new(nil) : Sidekiq.logger

  config.redis = { url: redis_url }
end